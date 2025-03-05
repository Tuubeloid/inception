FROM alpine:3.20.5

RUN apk update && apk add bash curl mariadb-client icu-data-full ghostscript \
	imagemagick openssl php82 php82-fpm php82-phar php82-json php82-mysqli \
	php82-curl php82-dom php82-exif php82-fileinfo php82-pecl-igbinary \
	php82-pecl-imagick php82-intl php82-mbstring php82-openssl \
	php82-xml php82-zip php82-iconv php82-shmop php82-simplexml php82-sodium \
	php82-xmlreader php82-zlib php82-tokenizer
 
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/bin/wp

COPY conf/www.conf /etc/php82/php-fpm.d/
 
COPY tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

RUN adduser -S www-data -G www-data

WORKDIR /var/www/html

EXPOSE 9000

# Install curl for healthcheck
RUN apk add --no-cache curl

# Healthcheck to see if PHP-FPM is alive
HEALTHCHECK --interval=5s --timeout=3s --retries=10 CMD curl -f http://localhost:9000 || exit 1

ENTRYPOINT [ "sh", "/usr/local/bin/entrypoint.sh" ]
