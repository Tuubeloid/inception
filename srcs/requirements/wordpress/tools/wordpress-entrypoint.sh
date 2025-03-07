#!/bin/bash
set -e

echo "🔍 Checking database connection..."

# Ensure MariaDB is ready before proceeding
MAX_TRIES=30
TRIES=0

while ! mysql -h"$WORDPRESS_DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; do
    TRIES=$((TRIES + 1))
    echo "Waiting for MariaDB ($TRIES/$MAX_TRIES)..."

    if [ "$TRIES" -ge "$MAX_TRIES" ]; then
        echo "❌ MariaDB is not responding. Exiting."
        exit 1
    fi

    sleep 3
done

echo "✅ MariaDB is ready! Waiting for DB stabilization..."
sleep 3  # Wait to ensure database is fully initialized

# Ensure the `www-data` user exists (for PHP-FPM)
if ! id www-data >/dev/null 2>&1; then
    echo "👤 Creating www-data user..."
    addgroup -g 1000 www-data || true
    adduser -D -H -u 1000 -G www-data www-data || true
else
    echo "✅ www-data user already exists, skipping creation."
fi

# Ensure PHP-FPM config exists before modifying it
if [ -f /etc/php83/php-fpm.d/www.conf ]; then
    sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf
fi

# WordPress Installation Check (Now checking inside /var/www/html/)
if [ ! -f /var/www/html/wp-config.php ] || [ ! -d /var/www/html/wp-admin ]; then
    echo "📥 Installing WordPress..."
    wp core download --allow-root --path=/var/www/html

    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --path=/var/www/html \
        --allow-root

    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --path=/var/www/html \
        --allow-root \
        --skip-email

    echo "✅ WordPress setup complete!"
else
    echo "✅ WordPress already installed. Skipping installation."
fi

# Ensure WordPress user exists
if ! wp user get "$WORDPRESS_USER" --path=/var/www/html --allow-root > /dev/null 2>&1; then
    echo "👤 Creating WordPress user '$WORDPRESS_USER'..."
    wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" \
        --user_pass="$WORDPRESS_PASSWORD" \
        --role=subscriber \
        --path=/var/www/html \
        --allow-root
    echo "✅ WordPress user '$WORDPRESS_USER' created."
else
    echo "✅ WordPress user '$WORDPRESS_USER' already exists."
fi

# Optimize MySQL and WordPress configuration
echo "⚙️ Updating wp-config.php..."
if ! grep -q "WP_MEMORY_LIMIT" /var/www/html/wp-config.php; then
    cat <<EOF >> /var/www/html/wp-config.php
define('FS_METHOD', 'direct');
define('WP_ALLOW_REPAIR', true);
define('WP_MEMORY_LIMIT', '512M');
define('WP_MAX_MEMORY_LIMIT', '512M');
define('DB_HOST', '$WORDPRESS_DB_HOST');
EOF
fi

# Fix permissions
echo "🔧 Setting correct file permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "✅ Finished configuration!"

# Start PHP-FPM
echo "🚀 Starting PHP-FPM..."
exec php-fpm83 -F

# Start PHP-FPM
echo "🚀 Starting PHP-FPM..."
exec php-fpm83 -F
