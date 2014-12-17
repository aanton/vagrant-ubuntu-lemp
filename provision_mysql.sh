#!/usr/bin/env bash

MYSQL_ROOT_PASSWORD=$1
MYSQL_REMOTE_ENABLED=$2

################################################################################

echo ">>> Installing MYSQL 5.6"

# Force a blank root password for MySQL
# https://gist.github.com/sheikhwaqas/9088872
echo "mysql-server-5.6 mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections

# Add repository with the latest MySQL packages
add-apt-repository -y ppa:ondrej/mysql-5.6
apt-get update -q

# -qq implies -y --force-yes
apt-get install -qq mysql-server-5.6 mysql-client-5.6

################################################################################

if [[ ${MYSQL_REMOTE_ENABLED} == "true" ]]; then
    echo ">>> Configuring MYSQL remote access"

    # Make MySQL connectable from outside world without SSH tunnel
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # Adding grant privileges to mysql root user from everywhere
    MYSQL_QUERY="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;FLUSH PRIVILEGES;"
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "${MYSQL_QUERY}"

    service mysql restart
fi

################################################################################

echo ">>> Checking MYSQL"

mysql --version
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SELECT User, Host FROM mysql.user;"

################################################################################