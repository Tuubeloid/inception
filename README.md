# 🚀 Inception VM Project Documentation

## 📌 Introduction
This project is designed to enhance system administration skills using Docker. Multiple Docker images will be virtualized within a VM, ensuring structured deployment, security, and modularity.

## 📜 Guidelines
- The project must be completed in a Virtual Machine (VM).
- All configuration files should be placed in `srcs/`.
- A `Makefile` must set up the application via `docker-compose.yml`.

## 🔧 Required Services
- **NGINX** (TLSv1.2/1.3 only, acts as the reverse proxy).
- **WordPress + PHP-FPM** (configured without NGINX, connects to MariaDB).
- **MariaDB** (Database for WordPress, separate from NGINX).
- **Volumes** for WordPress database and website files.
- **Docker Network** to securely link services.

## ⚠️ Constraints

![image](https://github.com/user-attachments/assets/a9b8682d-a87d-461f-b4d1-070b6d709526)

- Containers must auto-restart on failure.
- `network: host`, `--link`, and `links:` cannot be used.
- Avoid infinite loops (`tail -f`, `bash`, `sleep infinity`).
- The WordPress admin username **must not** contain `admin` or `administrator`.
- Volumes must be stored in `/home/data/`.
- The domain `.42.fr` must point to the local IP.
- **NGINX** must be the sole entry point via port `443` using **TLSv1.2/1.3**.

## 🔑 Environment Variables (.env File)
```ini
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
```

---

## 📄 Docker Compose Documentation
This `docker-compose.yml` file defines and manages the services used in the Inception project. Below is a breakdown of its functionality:

```yaml
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
      - "443:443" # HTTPS
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
```

### 🔍 Explanation of Docker Compose Services
- **MariaDB:**
  - Uses environment variables from `.env` to configure the database.
  - Stores database files in a volume at `~/data/mariadb`.
  - Includes a health check to verify if MySQL is responding.

- **NGINX:**
  - Acts as the reverse proxy for WordPress.
  - Uses a self-signed SSL certificate for HTTPS communication.
  - Exposes port `443` for secure access.
  - Depends on the WordPress service to be ready before starting.

- **WordPress:**
  - Uses environment variables from `.env` to set up the site.
  - Stores website files in a volume at `~/data/wordpress`.
  - Depends on MariaDB and waits for it to be healthy before starting.
  - Includes a health check to verify that WordPress is properly installed.

### 📦 Volumes & Networks
- **Volumes** ensure persistent data storage for MariaDB and WordPress files.
- **The `inception` network** is a custom Docker bridge network that allows all containers to communicate securely.

---

## 🔥 Running the Project
```sh
cd ~/Inception/srcs
make
```
🚀 Your services should now be running inside Docker! 🎉

---

📢 **More Features Coming Soon!**

🔗 **Stay Connected!** 💬 Have questions? [Open an Issue](https://github.com/tvalimak/inception/issues) or connect via [GitHub Discussions](https://github.com/tvalimak/inception/discussions)!




