#!/usr/bin/env bash
# $1: php_timezone

################################################################################

echo ">>> Installing PHP"

# -qq implies -y --force-yes
apt-get install -qq php5-cli
apt-get install -qq php5-curl php5-gd php5-imagick php5-json php5-mcrypt
apt-get install -qq php5-mysql php5-sqlite
apt-get install -qq php5-memcached

################################################################################

echo ">>> Installig/updating Composer"

composer --version
COMPOSER_CHECK=$?

if [[ $COMPOSER_CHECK -ne 0 ]]; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
else
    composer self-update
fi

################################################################################

echo ">>> Installing & configuring PHP-FPM"

apt-get install -qq php5-fpm

# Set PHP FPM to listen on TCP instead of Socket
sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php5/fpm/pool.d/www.conf

# Set PHP FPM allowed clients IP address
sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php5/fpm/pool.d/www.conf

# Set run-as user for PHP5-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sed -i "s/user = www-data/user = vagrant/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/.*listen\.mode.*/listen.mode = 0666/" /etc/php5/fpm/pool.d/www.conf

################################################################################

echo ">>> Installing & configuring XDEBUG"

apt-get install -qq php5-xdebug

# Configure xDebug
cat > $(find /etc/php5 -name xdebug.ini) << EOF
zend_extension=$(find /usr/lib/php5 -name xdebug.so)
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1

; var_dump display
xdebug.var_display_max_depth = 5
xdebug.var_display_max_children = 256
xdebug.var_display_max_data = 1024
EOF

################################################################################

echo ">>> Configuring PHP"

# Error Reporting
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini

# Date Timezone
sed -i "s/;date.timezone =.*/date.timezone = ${1/\//\\/}/" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone =.*/date.timezone = ${1/\//\\/}/" /etc/php5/cli/php.ini

# opCache
# https://www.scalingphpbook.com/best-zend-opcache-settings-tuning-config/
sed -i "s/.*opcache.enable=.*/opcache.enable=1/" /etc/php5/fpm/php.ini
sed -i "s/.*opcache.fast_shutdown=.*/opcache.fast_shutdown=1/" /etc/php5/fpm/php.ini
sed -i "s/.*opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php5/fpm/php.ini
sed -i "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=4000/" /etc/php5/fpm/php.ini
sed -i "s/.*opcache.memory_consumption=.*/opcache.memory_consumption=64/" /etc/php5/fpm/php.ini
sed -i "s/.*opcache.revalidate_freq=.*/opcache.revalidate_freq=0/" /etc/php5/fpm/php.ini
sed -i "s/.*opcache.validate_timestamps=.*/opcache.validate_timestamps=1/" /etc/php5/fpm/php.ini

service php5-fpm restart

################################################################################

echo ">>> Checking PHP"

php --version

################################################################################