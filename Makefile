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
