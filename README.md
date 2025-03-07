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

![image](https://github.com/user-attachments/assets/9f46df6c-969c-45f8-a8d9-3c3f7aef9400)

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

# 🏗 Step-by-Step Instructions

## 🐳 Docker Installation
```sh
apk update && apk upgrade
apk add docker docker-compose
rc-update add docker boot
service docker start
service docker status  # Ensure Docker is running
addgroup tvalimak docker
apk add docker-cli-compose
```

---

## 📂 Project Setup
### 📌 Directory Structure
To ensure a proper project structure, execute the following commands inside your VM:

```sh
# Create the main project directory
mkdir -p ~/Inception/srcs

# Navigate into the project directory
cd ~/Inception/srcs

# Create essential files and folders
mkdir -p requirements/{mariadb,nginx,wordpress,tools}
touch docker-compose.yml .env

# Inside requirements, create necessary subdirectories
mkdir -p requirements/mariadb/{conf,tools}
mkdir -p requirements/nginx/{conf,tools}
mkdir -p requirements/wordpress/{conf,tools}

# Create necessary Dockerfiles and .dockerignore files
touch requirements/mariadb/{Dockerfile,.dockerignore}
touch requirements/nginx/{Dockerfile,.dockerignore}
touch requirements/wordpress/{Dockerfile,.dockerignore}
```

After creating the directories, verify the structure with:
```sh
tree ~/Inception
```

### 🔑 Setting Up Permissions
Run the following commands to ensure proper file permissions:
```sh
# Change ownership to your user
tmenkovi=tvalimak  # Adjust to match your username
chown -R $tmenkovi:$tmenkovi ~/Inception

# Set permissions for directories and files
chmod -R 775 ~/Inception/srcs
chmod 664 ~/Inception/srcs/docker-compose.yml
chmod 664 ~/Inception/srcs/.env
chmod -R 775 ~/Inception/srcs/requirements
chmod -R 664 ~/Inception/srcs/requirements/*/.dockerignore
chmod -R 664 ~/Inception/srcs/requirements/*/Dockerfile
```

---

## 📄 Makefile Documentation
This `Makefile` automates the setup, management, and cleanup of the Inception project. Below is a breakdown of its functionality:

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

### 🔍 Explanation of Makefile Targets
- **`all`**: Default target, runs `up` to build and start all services.
- **`up`**: Ensures the required directories exist and starts the containers with `docker-compose up --build -d`.
- **`down`**: Stops all running containers.
- **`re`**: Restarts all services by running `down` followed by `up`.
- **`clean`**: Stops all containers and removes the entire data directory.
- **`fclean`**: Performs `clean`, removes all container volumes, and deletes all Docker images used in the project.
- **`ps`**: Lists all running containers.
- **`logs`**: Displays logs from all running containers.
- **`volumes`**: Lists all Docker volumes and inspects the `srcs_mariadb` and `srcs_wordpress` volumes.
- **`$(MARIADB) $(WORDPRESS)`**: Ensures that the required directories exist before starting services.

---

## 🔥 Running the Project
```sh
cd ~/Inception/srcs
make
```
🚀 Your services should now be running inside Docker! 🎉

---

📢 **More Features Coming Soon!**
