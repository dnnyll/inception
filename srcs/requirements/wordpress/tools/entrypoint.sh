#!/bin/sh
set -eu

mkdir -p /run/php /var/www/html

: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"
: "${DOMAIN_NAME:?DOMAIN_NAME is not set}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is not set}"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is not set}"

MYSQL_PASSWORD="$(cat /run/secrets/db_password)"

if [ ! -f /var/www/html/index.php ]; then
    echo "Downloading WordPress..."
    curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz \
        --strip-components=1 \
        -C /var/www/html
    rm -f /tmp/wordpress.tar.gz
fi

chown -R www-data:www-data /var/www/html

until mariadb \
    --host=mariadb \
    --user="$MYSQL_USER" \
    --password="$MYSQL_PASSWORD" \
    --database="$MYSQL_DATABASE" \
    -e "SELECT 1" >/dev/null 2>&1
do
    echo "Waiting for MariaDB..."
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --path=/var/www/html \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --path=/var/www/html \
        --url="https://$DOMAIN_NAME" \
        --title="Inception WordPress" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
fi

sed -i 's|^listen = .*|listen = 9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

exec php-fpm8.2 -F
