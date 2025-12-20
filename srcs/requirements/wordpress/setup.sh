#!/bin/sh

set -e

DB_NAME="$MYSQL_DATABASE"
DB_USER="$MYSQL_USER"
DB_PASS="$(cat /run/secrets/db_user_password)"
DB_HOST="mariadb"

if [ ! -f wp-config.php ]; then

    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* .
    rm -rf wordpress latest.tar.gz

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/$DB_NAME/" wp-config.php
    sed -i "s/username_here/$DB_USER/" wp-config.php
    sed -i "s/password_here/$DB_PASS/" wp-config.php
    sed -i "s/localhost/$DB_HOST/" wp-config.php

fi

# starting the php engine in foreground
exec php-fpm8.2 -F