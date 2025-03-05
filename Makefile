DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := srcs/.env
DATA_DIR := $(HOME)/data
WORDPRESS_DATA_DIR := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR := $(DATA_DIR)/mariadb

name = inception

all: create_dirs make_dir_up

build: create_dirs make_dir_up_build

down:
	@printf "Stopping configuration ${name}...\n"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down

re: down create_dirs make_dir_up_build

clean: down
	@printf "Cleaning configuration ${name}... \n"
	@docker system prune -af                # -a to remove unused images and -f to skip the confirmation
	@sudo rm -rf $(WORDPRESS_DATA_DIR)/*
	@sudo rm -rf $(MARIADB_DATA_DIR)/*

fclean: clean
	@printf "Total clean of all configurations docker\n"
	@docker volume rm $$(docker volume ls -q) || true
	@docker system prune -af --volumes      # Prune volumes too
	@sudo rm -rf $(DATA_DIR)

logs:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) logs -f

create_dirs:
	@printf "Creating data directories...\n"
	@sudo mkdir -p $(WORDPRESS_DATA_DIR)
	@sudo mkdir -p $(MARIADB_DATA_DIR)

make_dir_up:
	@printf "Launching configuration ${name}...\n"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d

make_dir_up_build:
	@printf "Launching configuration ${name} with --build...\n"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up --build -d
