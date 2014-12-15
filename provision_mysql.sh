#!/usr/bin/env bash
# $1: mysql_root_password
# $2: mysql_enable_remote

################################################################################

echo ">>> Installing MYSQL 5.6"

# Force a blank root password for MySQL
# https://gist.github.com/sheikhwaqas/9088872
echo "mysql-server-5.6 mysql-server/root_password password $1" | debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password $1" | debconf-set-selections

# -qq implies -y --force-yes
apt-get install -qq mysql-server-5.6 mysql-client-5.6

################################################################################

if [[ $2 == true ]]; then
    echo ">>> Configuring MYSQL remote access"

    # Make MySQL connectable from outside world without SSH tunnel
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # Adding grant privileges to mysql root user from everywhere
    MYSQL_QUERY="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;FLUSH PRIVILEGES;"
    mysql -uroot -p$1 -e "$MYSQL_QUERY"

    service mysql restart
fi

################################################################################

echo ">>> Checking MYSQL"

mysql --version
mysql -uroot -p$1 -e "SELECT User, Host FROM mysql.user;"

################################################################################