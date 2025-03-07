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

---

## 🖥 Virtual Machine Setup
### 🔹 Installing VirtualBox
- [Download VirtualBox](https://www.virtualbox.org/)
- [Download Alpine Linux](https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/) (alpine-virt-3.20.4-x86_64.iso)

### 🔹 Virtual Machine Configuration
1. Open **VirtualBox** and create a new VM named `Inception`.
2. Set **folder location** to `goinfre` or your USB drive.
3. Select **ISO Image** (Alpine), **Type:** Linux, **Version:** Other Linux (64-bit).
4. Set **Base Memory** to `2048MB`, **Processors** to `1 CPU`.
5. Set **Virtual Hard Disk size** to `30GB`.
6. Click **Finish**.
7. Open **Settings** → **Storage** → **Optical Drive** → Select Alpine ISO.
8. Click **Start** and proceed with installation.

### 🔹 Setting Up Alpine Linux
1. **Login as** `root`.
2. Run `setup-alpine` and follow the prompts:
   - Keyboard Layout: `us`
   - Hostname: `tvalimak.42.fr`
   - Set up **password and timezone**.
   - Install to disk (`sda` → `sys` → `y`).
3. Remove the **installation disk** and reboot.
4. Login as `root` and set up `sudo`:
   ```sh
   vi /etc/apk/repositories  # Uncomment the last line
   apk update
   apk add sudo
   visudo  # Uncomment %sudo ALL=(ALL:ALL) ALL
   addgroup sudo
   adduser tvalimak sudo
   ```
5. **Configure SSH**:
   ```sh
   apk add nano openssh
   nano /etc/ssh/sshd_config
   ```
   - Uncomment `Port` and set it to `4241`.
   - Change `PermitRootLogin` to `no`.
   - Save and exit (`CTRL+O`, `Enter`, `CTRL+X`).
   ```sh
   rc-service sshd restart
   netstat -tuln | grep 4241  # Verify SSH is listening
   ```
6. **Set up SSH Port Forwarding in VirtualBox**:
   - Open **Settings** → **Network** → **Advanced** → **Port Forwarding**.
   - Add a rule: **Host Port** = `4241`, **Guest Port** = `4241`.
   - Click OK.
7. **Test SSH Connection**:
   ```sh
   ssh localhost -p 4241
   ```

---

## 🐳 Docker Installation & Setup
### 🔹 Installing Docker
```sh
ssh localhost -p 4241
sudo apk update && sudo apk upgrade
sudo vi /etc/apk/repositories  # Uncomment first line, save & close
sudo apk add docker docker-compose
sudo apk add --update docker openrc
```
### 🔹 Starting Docker
```sh
sudo rc-update add docker boot
service docker status  # Ensure it's running
sudo service docker start  # Start if stopped
```
### 🔹 Add User to Docker Group
```sh
sudo addgroup tvalimak docker
sudo apk add docker-cli-compose
```

---

## 📄 Explanation for Makefile
The `Makefile` automates the building, running, and management of Docker services.
- **`up`**: Builds and starts the containers.
- **`down`**: Stops and removes the running containers.
- **`re`**: Restarts the services by executing `down` followed by `up`.
- **`clean`**: Removes the entire data directory.
- **`fclean`**: Performs `clean`, removes container volumes, and deletes all Docker images used.
- **`ps`**: Lists the running containers.
- **`logs`**: Displays logs from running containers.
- **`volumes`**: Lists and inspects the Docker volumes.

```makefile
COMPOSE_FILE   := srcs/docker-compose.yml
DOCKER_COMPOSE := docker compose -f $(COMPOSE_FILE)

DATADIR := $(HOME)/data
MARIADB := $(DATADIR)/mariadb
WORDPRESS := $(DATADIR)/wordpress

all: up

up: $(MARIADB) $(WORDPRESS)
	@$(DOCKER_COMPOSE) up --build -d

down:
	@$(DOCKER_COMPOSE) down

re: down up

clean: down
	sudo rm -rf $(DATADIR)

fclean: clean
	@$(DOCKER_COMPOSE) down -v --rmi all

ps:
	@$(DOCKER_COMPOSE) ps

logs:
	@$(DOCKER_COMPOSE) logs

volumes:
	docker volume ls
	docker volume inspect srcs_mariadb
	docker volume inspect srcs_wordpress

$(MARIADB) $(WORDPRESS):
	mkdir -p $@

.PHONY: all up down re clean fclean ps logs volumes
```

---

## 📄 Explanation for docker-compose.yml
The `docker-compose.yml` defines the services and configurations for the project.

- **MariaDB**: Sets up the database service and ensures it is healthy before WordPress starts.
- **NGINX**: Serves as the reverse proxy for WordPress over HTTPS.
- **WordPress**: Installs and configures WordPress, waiting for MariaDB before launching.
- **Volumes**: Stores persistent data for both MariaDB and WordPress.
- **Network**: Ensures secure communication between the services.

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

---

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



