#!/bin/bash

set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
MYSQL_SECOND_PASSWORD="$(cat /run/secrets/db_second_password)"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"
: "${MYSQL_SECOND_USER:?MYSQL_SECOND_USER is not set}"

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."

    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql

    mysqld_safe \
        --datadir=/var/lib/mysql \
        --skip-networking &

    TEMP_SERVER_PID=$!

    until mariadb-admin ping --silent; do
        sleep 1
    done

    mariadb -u root <<EOSQL
DROP USER IF EXISTS ''@'localhost';
DROP USER IF EXISTS ''@'${HOSTNAME}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
    IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.*
    TO '${MYSQL_USER}'@'%';

CREATE USER IF NOT EXISTS '${MYSQL_SECOND_USER}'@'%'
    IDENTIFIED BY '${MYSQL_SECOND_PASSWORD}';

GRANT SELECT, INSERT, UPDATE, DELETE
    ON \`${MYSQL_DATABASE}\`.*
    TO '${MYSQL_SECOND_USER}'@'%';

ALTER USER 'root'@'localhost'
    IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOSQL

    mariadb-admin \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" \
        shutdown

    wait "$TEMP_SERVER_PID" 2>/dev/null || true

    echo "MariaDB initialization complete."
fi

exec mysqld \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --bind-address=0.0.0.0
