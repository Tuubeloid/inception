FROM alpine:3.20.5

# Install dependencies (Optimized installation to reduce layers)
RUN apk update && apk add --no-cache \
    bash curl mariadb-client icu-data-full ghostscript \
    imagemagick openssl \
    php82 php82-fpm php82-cli php82-phar php82-json php82-mysqli \
    php82-curl php82-dom php82-exif php82-fileinfo php82-pecl-igbinary \
    php82-pecl-imagick php82-intl php82-mbstring php82-openssl \
    php82-xml php82-zip php82-iconv php82-shmop php82-simplexml \
    php82-sodium php82-xmlreader php82-zlib php82-tokenizer \
    && rm -rf /var/cache/apk/*  # Remove cache after install

# Install WP CLI securely (Verify checksum)
RUN curl -o /usr/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/bin/wp

# Add custom PHP configuration (More efficient writing)
RUN echo "memory_limit = 512M" > /etc/php82/conf.d/99-custom.ini \
    && echo "upload_max_filesize = 512M" >> /etc/php82/conf.d/99-custom.ini \
    && echo "post_max_size = 512M" >> /etc/php82/conf.d/99-custom.ini \
    && echo "max_execution_time = 300" >> /etc/php82/conf.d/99-custom.ini \
    && echo "max_input_time = 300" >> /etc/php82/conf.d/99-custom.ini

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php82/php-fpm.d/

# Copy custom entrypoint script & ensure it's executable
COPY tools/wordpress-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

# Add user for running the web service
RUN adduser -S www-data -G www-data

# Ensure WordPress directory exists and is writable
RUN mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html

# Set working directory
WORKDIR /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Healthcheck to monitor PHP-FPM
HEALTHCHECK --interval=10s --timeout=5s --retries=10 CMD curl -f http://localhost:9000 || exit 1

# Entrypoint to start the application
ENTRYPOINT [ "sh", "/usr/local/bin/wordpress-entrypoint.sh" ]

# Start PHP-FPM as the main process
CMD ["/usr/sbin/php-fpm82", "-F"]

# Start PHP-FPM as the main process
CMD ["/usr/sbin/php-fpm82", "-F"]
