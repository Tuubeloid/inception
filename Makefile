# Paths
COMPOSE_FILE   := srcs/docker-compose.yml
DOCKER_COMPOSE := docker compose -f $(COMPOSE_FILE)

# Data Directories
DATADIR   := $(HOME)/data
DB_DIR    := $(DATADIR)/mariadb
WP_DIR    := $(DATADIR)/wordpress

# Default target
all: up

## Start the Docker containers
up: $(DB_DIR) $(WP_DIR)
	@echo "🚀 Starting Docker containers..."
	@$(DOCKER_COMPOSE) up --build -d

## Stop and remove the containers
down:
	@echo "🛑 Stopping Docker containers..."
	@$(DOCKER_COMPOSE) down

## Restart the containers
re: down up

## Remove all persistent data
clean: down
	@echo "🧹 Cleaning up data directories..."
	sudo rm -rf $(DATADIR)

## Remove everything, including volumes and images
fclean: clean
	@echo "🔥 Removing all Docker volumes and images..."
	@$(DOCKER_COMPOSE) down -v --rmi all

## Show running containers
ps:
	@$(DOCKER_COMPOSE) ps

## Show container logs
logs:
	@$(DOCKER_COMPOSE) logs

## Show Docker volumes
volumes:
	@echo "📦 Listing Docker volumes..."
	docker volume ls
	docker volume inspect srcs_mariadb
	docker volume inspect srcs_wordpress

# Ensure data directories exist
$(DB_DIR) $(WP_DIR):
	@echo "📂 Creating data directories..."
	mkdir -p $@

# Declare phony targets
.PHONY: all up down re clean fclean ps logs volumes
