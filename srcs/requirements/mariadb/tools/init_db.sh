#!/bin/bash

# Stop the script if any command fails.
set -e

# Read the database password from the Docker secret file.
MYSQL_PASSWORD="$(cat /run/secrets/db_password)"

# Read the MariaDB root password from the Docker secret file.
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

# Check whether MariaDB has already been initialized.
if [ ! -d "/var/lib/mysql/mysql" ]; then

    # Initialize MariaDB's system tables and data directory.
    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql

    # Start a temporary MariaDB server without network access.
    mysqld_safe \
        --datadir=/var/lib/mysql \
        --skip-networking &

    # Wait until MariaDB is ready.
    until mariadb-admin ping --silent; do
        sleep 1
    done

    # Create the application database and user.
    mariadb -u root <<-EOSQL

        # Create the database.
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

        # Create the WordPress database user.
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
            IDENTIFIED BY '${MYSQL_PASSWORD}';

        # Give the user permissions on the WordPress database.
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.*
            TO '${MYSQL_USER}'@'%';

        # Set the MariaDB root password.
        ALTER USER 'root'@'localhost'
            IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

        # Reload MariaDB privileges.
        FLUSH PRIVILEGES;

EOSQL

    # Stop the temporary MariaDB server.
    mariadb-admin \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" \
        shutdown
fi

# Start MariaDB normally as the main container process.
exec mysqld \
    --user=mysql \
    --datadir=/var/lib/mysql
