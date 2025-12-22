COMPOSE_FILE	= srcs/docker-compose.yml
DATA_DIR		= /home/abel-baz/data

all: up printing

printing:
	@echo "\033[1;36m=======================================================================\033[0m"
	@echo "\033[1;32m✓ Inception is up and running!\033[0m  \033[36mAccess:\033[0m \033[1;34mhttps://abel-baz.42.fr\033[0m"
	@echo "\033[1;32m✓ MariaDB data:\033[0m \033[1;33m$(DATA_DIR)/mariadb\033[0m"
	@echo "\033[1;32m✓ WordPress data:\033[0m \033[1;33m$(DATA_DIR)/wordpress\033[0m"
	@echo "\033[1;35m→ To stop the services, run: \033[1;37mmake down\033[0m"
	@echo "\033[1;36m=======================================================================\033[0m"

up:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@docker compose -f $(COMPOSE_FILE) up -d --build

down:
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all

fclean: clean
	@sudo rm -rf $(DATA_DIR)/mariadb
	@sudo rm -rf $(DATA_DIR)/wordpress
	@docker system prune -af --volumes

re: fclean all

help:
	@echo "Makefile commands:"
	@echo "  make all       - Build and start all services"
	@echo "  make up        - Start services"
	@echo "  make down      - Stop services"
	@echo "  make clean     - Stop services and remove containers, networks, images, and volumes"
	@echo "  make fclean    - Clean and remove data directories"
	@echo "  make re        - Rebuild and restart all services"
	@echo "  make help      - Display this help message"

.PHONY: all up down clean fclean re printing