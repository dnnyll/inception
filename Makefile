NAME =		inception
COMPOSE =	sudo docker compose -f srcs/docker-compose.yml

all:		up

build:
		$(COMPOSE) build

up:
		$(COMPOSE) up -d

down:
		$(COMPOSE) down

clean:		down

fclean:		down
		sudo docker image rm -f srcs-nginx srcs-wordpress srcs-mariadb 2>/dev/null || true

re:		fclean build up

.PHONY:		all build up down clean fclean re
