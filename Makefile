# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tvalimak <tvalimak@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/01/26 10:37:23 by tvalimak          #+#    #+#              #
#    Updated: 2025/01/26 10:39:35 by tvalimak         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Project variables
NAME           = inception
DOCKER_COMPOSE = docker-compose
SRC_DIR        = ./srcs
COMPOSE_FILE   = $(SRC_DIR)/docker-compose.yml

# Colors for output (optional)
YELLOW = \033[33m
GREEN = \033[32m
RESET = \033[0m

# Targets
all: up

up: ## Start the containers
	@echo "$(YELLOW)Starting $(NAME)...$(RESET)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up --build -d
	@echo "$(GREEN)$(NAME) is running!$(RESET)"

down: ## Stop the containers
	@echo "$(YELLOW)Stopping $(NAME)...$(RESET)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down
	@echo "$(GREEN)$(NAME) is stopped!$(RESET)"

clean: down ## Stop and remove all containers, networks, and volumes
	@echo "$(YELLOW)Cleaning up containers, networks, and volumes...$(RESET)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v
	@docker system prune -f --volumes
	@echo "$(GREEN)Cleaned up all unused Docker resources!$(RESET)"

re: clean up ## Rebuild and restart the project
	@echo "$(YELLOW)Rebuilding $(NAME)...$(RESET)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up --build -d
	@echo "$(GREEN)$(NAME) is running with fresh build!$(RESET)"

logs: ## Show logs for all containers
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f

ps: ## Show running containers
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

build: ## Build the Docker images without starting the containers
	@echo "$(YELLOW)Building Docker images...$(RESET)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build
	@echo "$(GREEN)Docker images built successfully!$(RESET)"

help: ## Show available Makefile commands
	@echo "$(YELLOW)Available commands:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(RESET) %s\n", $$1, $$2}'

# Ignore these targets for automatic file generation
.PHONY: all up down clean re logs ps build help