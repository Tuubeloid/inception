FROM alpine:3.20.5

# Install PHP 8.3 and necessary dependencies
RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-curl \
    php83-dom \
    php83-mbstring \
    php83-openssl \
    php83-xml \
    php83-phar \
    php83-session \
    php83-gd \
    mariadb-client \
    wget \
    bash \
    ca-certificates \
    shadow  # Adds usermod & groupmod for managing users

# ✅ Ensure the www-data user and group exist
RUN getent group www-data || addgroup -g 1000 www-data && \
    id -u www-data &>/dev/null || adduser -D -H -u 1000 -G www-data www-data

# Create WordPress directory and install WP CLI
RUN mkdir -p /var/www/html && \
    wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

# Copy WordPress entrypoint script
COPY tools/wordpress-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

# Set working directory
WORKDIR /var/www/html

# Add custom PHP configurations
RUN echo "memory_limit = 512M" > /etc/php83/conf.d/99-custom.ini && \
    echo "upload_max_filesize = 512M" >> /etc/php83/conf.d/99-custom.ini && \
    echo "post_max_size = 512M" >> /etc/php83/conf.d/99-custom.ini && \
    echo "max_execution_time = 300" >> /etc/php83/conf.d/99-custom.ini && \
    echo "max_input_time = 300" >> /etc/php83/conf.d/99-custom.ini

# ✅ Fix permissions AFTER www-data exists
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Set the entrypoint script
ENTRYPOINT [ "/usr/local/bin/wordpress-entrypoint.sh" ]

# Start PHP-FPM as the main process
CMD ["/usr/sbin/php-fpm83", "-F"]
