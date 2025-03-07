Inception VM Project Documentation

Introduction

This project enhances system administration skills using Docker. Multiple Docker images will be virtualized within a VM, ensuring a structured deployment of services while maintaining security and modularity.

Guidelines

The project must be completed in a Virtual Machine (VM).

All configuration files should be placed in srcs/.

A Makefile must set up the application via docker-compose.yml.

Required Services

NGINX (TLSv1.2/1.3 only, serves as the reverse proxy).

WordPress + PHP-FPM (configured without NGINX, connects to MariaDB).

MariaDB (Database management for WordPress, runs separately from NGINX).

Volumes for WordPress database and website files.

Docker Network to link services securely.

Constraints

Containers must auto-restart on failure.

network: host, --link, and links: cannot be used.

Infinite loops (e.g., tail -f, bash, sleep infinity) must be avoided.

The WordPress admin username must not contain admin or administrator.

Volumes must be stored in /home//data/.

The domain .42.fr must point to the local IP.

NGINX must be the sole entry point via port 443, using TLSv1.2/1.3.

Environment Variables (.env File)

DOMAIN_NAME=tvalimak.42.fr

SSL_CERT_PATH=/etc/ssl/certs/selfsigned.crt
SSL_KEY_PATH=/etc/ssl/private/selfsigned.key

WORDPRESS_DB_HOST=mariadb:3306

MYSQL_USER=tvalimak
MYSQL_PASSWORD=userpass
MYSQL_DATABASE=wordpress
MYSQL_ROOT_PASSWORD=rootpass
WORDPRESS_TITLE=Inception
WORDPRESS_ADMIN_USER=user666
WORDPRESS_ADMIN_PASSWORD=pass
WORDPRESS_ADMIN_EMAIL=admin666@gmail.com
WORDPRESS_USER=tvalimak
WORDPRESS_PASSWORD=pass
WORDPRESS_EMAIL=user666@gmail.com

Step-by-Step Instructions

1. Virtual Machine Setup

Installing VirtualBox

Download and install VirtualBox.

Download Alpine Linux (alpine-virt-3.20.4-x86_64.iso).

Virtual Machine Configuration

Open VirtualBox and create a new VM named Inception.

Set folder location to goinfre or your USB drive.

Select ISO Image (Alpine), Type: Linux, Version: Other Linux (64-bit).

Set Base Memory to 2048MB, Processors to 1 CPU.

Set Virtual Hard Disk size to 30GB.

Click Finish.

Open Settings > Storage > Optical Drive > Choose the Alpine ISO.

Click Start and proceed with installation.

Setting Up Alpine Linux

Login as root.

Run setup-alpine and follow prompts:

Keyboard Layout: us

Hostname: tvalimak.42.fr

Set up password and timezone.

Install to disk (sda > sys > y).

Remove the installation disk and reboot.

Login as root and set up sudo:

vi /etc/apk/repositories  # Uncomment the last line
apk update
apk add sudo
visudo  # Uncomment %sudo ALL=(ALL:ALL) ALL
addgroup sudo
adduser tvalimak sudo

2. SSH Installation & Configuration

apk update
apk add nano openssh
nano /etc/ssh/sshd_config

Uncomment Port and set it to 4241.

Change PermitRootLogin to no.

Save and exit (CTRL+O, Enter, CTRL+X).

rc-service sshd restart
netstat -tuln | grep 4241  # Verify SSH is listening

Open VirtualBox Settings > Network > Advanced > Port Forwarding

Add a rule: Host Port = 4241, Guest Port = 4241.

Test connection:

ssh localhost -p 4241

3. Docker Installation

apk update && apk upgrade
apk add docker docker-compose
rc-update add docker boot
service docker start
service docker status  # Ensure Docker is running
addgroup tvalimak docker
apk add docker-cli-compose

4. Project Setup

Directory Structure

mkdir -p ~/Inception/srcs/requirements/{mariadb,nginx,wordpress}/conf
mkdir -p ~/Inception/srcs/requirements/{mariadb,nginx}/tools
touch ~/Inception/srcs/docker-compose.yml ~/Inception/srcs/.env

Verify the structure:

tree ~/Inception

Setting Up File Permissions

chown -R tvalimak:tvalimak ~/Inception
chmod -R 775 ~/Inception/srcs
chmod 664 ~/Inception/srcs/docker-compose.yml
chmod 664 ~/Inception/srcs/.env

5. Docker Configuration

Creating Dockerfiles

Inside mariadb/Dockerfile:

FROM alpine:3.20.5
RUN apk update && apk add --no-cache mariadb mariadb-client gettext /* I used gettext to overwrite variables in configuration files with env variables, separation of concerns */
RUN mkdir -p /run/mysqld /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld
COPY ./conf/my.cnf /etc/mysql/
RUN chmod 644 /etc/mysql/my.cnf
COPY tools/init.sql /etc/mysql/
RUN chmod 644 /etc/mysql/init.sql
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh
EXPOSE 3306
ENTRYPOINT [ "sh", "/usr/local/bin/mariadb-entrypoint.sh" ]

Inside init.sql:

-- Drop the database if it exists, then create a new one
DROP DATABASE IF EXISTS `${MYSQL_DATABASE}`;
CREATE DATABASE `${MYSQL_DATABASE}`;

-- Manually set the password for the root user
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Create the user if it doesn't already exist and set permissions
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON `${MYSQL_DATABASE}`.* TO '${MYSQL_USER}'@'%';

-- Apply changes
FLUSH PRIVILEGES;

Inside nginx/Dockerfile:

FROM alpine:3.20.5 

# Update and install necessary packages
RUN apk update && apk add --no-cache nginx openssl curl

# Create necessary directories for SSL certificates
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate SSL certificates for NGINX (self-signed certificate)
RUN openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt -days 365 -nodes -subj "/C=FI/L=Helsinki/O=Hive/OU=Student/CN=tvalimak.42.fr"

# Set the correct permissions for the SSL certificate and key
RUN chmod 644 /etc/ssl/certs/selfsigned.crt && chmod 600 /etc/ssl/private/selfsigned.key

# Copy NGINX configuration file
COPY conf/nginx.conf /etc/nginx/
RUN chmod 644 /etc/nginx/nginx.conf

# Copy entrypoint script for custom configuration at startup
COPY tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

# Debug Line 🔥 (temporary)
RUN ls -la /usr/local/bin/ && ls -la /etc/ssl/certs/ && ls -la /etc/ssl/private/

# Expose port 443 for HTTPS
EXPOSE 443

# Healthcheck to verify that NGINX is serving over HTTPS
HEALTHCHECK --interval=5s --timeout=3s --retries=10 CMD curl -kf https://localhost || exit 1

# Use the entrypoint script to configure NGINX at runtime
ENTRYPOINT ["sh", "/usr/local/bin/nginx-entrypoint.sh"]

Inside wordpress/Dockerfile:

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

Configuring docker-compose.yml

services:
  mariadb:
    container_name: mariadb
    init: true
    restart: always
    env_file:
      - .env
    build: requirements/mariadb
    volumes:
      - mariadb:/var/lib/mysql
    networks:
      - inception
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      retries: 5

  nginx:
    container_name: nginx
    init: true
    restart: always
    environment:
      - DOMAIN_NAME=${DOMAIN_NAME}
    env_file:
      - .env
    build: requirements/nginx
    ports:
      - "443:443" #https
    volumes:
      - wordpress:/var/www/html
    networks:
      - inception
    depends_on:
      - wordpress

  wordpress:
    container_name: wordpress
    init: true
    restart: always
    env_file:
      - .env
    build: requirements/wordpress
    volumes:
      - wordpress:/var/www/html
    networks:
      - inception
    depends_on:
      mariadb:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "test", "-f", "/var/www/html/wp-login.php"]
      interval: 30s
      timeout: 10s
      retries: 5

volumes:
  mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ~/data/mariadb
  wordpress:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ~/data/wordpress

networks:
  inception:
    driver: bridge

6. Running the Project

cd ~/Inception/srcs
make

Your services should now be running inside Docker!
