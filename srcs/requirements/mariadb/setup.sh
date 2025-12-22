#!/bin/sh
set -e

DB_NAME="$MYSQL_DATABASE"
DB_USER="$MYSQL_USER"
DB_PASS="$(cat /run/secrets/db_user_password)"


if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "=> Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

fi

# allow remote connections
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# on the container we miss this DIR for socket file
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# wrapped script that handles mysqld
mysqld_safe &

sleep 7s

mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mysqladmin shutdown

exec mysqld_safe

