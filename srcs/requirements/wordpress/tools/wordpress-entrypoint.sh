#!/bin/bash
set -e
cd /var/www/html

# Ensure PHP-FPM config exists before modifying it
if [ -f /etc/php83/php-fpm.d/www.conf ]; then
    sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf
fi

# Ensure WordPress is installed
if [ ! -f wp-config.php ]; then
    echo "Installing WordPress..."
    wp core download --allow-root
    wp config create --allow-root --dbhost=mariadb --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbname="$MYSQL_DATABASE"
    wp core install --allow-root --skip-email --url="$DOMAIN_NAME" --title="$WORDPRESS_TITLE" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL"
fi

# Fix permissions
chmod -R 755 /var/www/html
chown -R www-data:www-data /var/www/html

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec php-fpm83 -F
