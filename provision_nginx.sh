#!/usr/bin/env bash

HOSTNAME=$1
SERVER_PRIVATE_IP=$2
WEBSERVER_DOCROOT=$3

################################################################################

echo ">>> Installing NGINX"

# -qq implies -y --force-yes
apt-get install -qq nginx

nginx -v

################################################################################

echo ">>> Configuring NGINX"

# There is a VirtualBox bug related to sendfile which can result in corrupted or non-updating files
# https://docs.vagrantup.com/v2/synced-folders/virtualbox.html
sed -i 's/sendfile on;/sendfile off;/' /etc/nginx/nginx.conf

# Set run-as user for PHP5-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

# Add vagrant user to www-data group
usermod -a -G www-data vagrant

################################################################################

echo ">>> Configuring PHP-FPM for NGINX"

sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
service php5-fpm restart

################################################################################

echo ">>> Configuring ${HOSTNAME} host in ${WEBSERVER_DOCROOT}"

# Create server block
read -d '' NGINX_SITE <<EOF
server {
    listen 80;
    server_name ${HOSTNAME} ${HOSTNAME}.${SERVER_PRIVATE_IP}.xip.io;

    root ${WEBSERVER_DOCROOT};
    index index.html index.htm index.php;
    charset utf-8;

    access_log /var/log/nginx/${HOSTNAME}-access.log;
    error_log  /var/log/nginx/${HOSTNAME}-error.log error;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    # pass the PHP scripts to php5-fpm
    # Note: \.php$ is susceptible to file upload attacks
    # Consider using: "location ~ ^/(index|app|app_dev|config)\.php(/|$) {"
    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        # With php5-fpm:
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTPS off;
    }

    # Deny .htaccess file access
    location ~ /\.ht {
        deny all;
    }
}
EOF

# Create docroot directory if not exists
if [[ ! -d ${WEBSERVER_DOCROOT} ]]; then
    mkdir -p ${WEBSERVER_DOCROOT}
fi

# Create site & enable it
echo "${NGINX_SITE}" > /etc/nginx/sites-available/${HOSTNAME}
ln -sf /etc/nginx/sites-available/${HOSTNAME} /etc/nginx/sites-enabled/${HOSTNAME}

# Check enabled sites
egrep "server_name |root " /etc/nginx/sites-available/*

################################################################################

echo ">>> Restarting NGINX"

service nginx restart

################################################################################