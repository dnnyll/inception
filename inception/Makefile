NAME = inception
COMPOSE = sudo docker compose -f srcs/docker-compose.yml

all: up

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs

logs-follow:
	$(COMPOSE) logs -f

config:
	$(COMPOSE) config

users:
	$(COMPOSE) exec wordpress \
		wp user list --path=/var/www/html --allow-root

tree:
	tree -a -I '.git|secrets'

secret-tree:
	tree -a secrets

clean: down

fclean: down
	sudo docker image rm -f srcs-nginx srcs-wordpress srcs-mariadb 2>/dev/null || true

re: fclean build up

.PHONY: all build up down restart status logs logs-follow config users tree secret-tree clean fclean re
