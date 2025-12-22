# Developer Documentation

## Setting Up the Environment from Scratch

### Prerequisites

Ensure the following are installed:
```bash
# Check Docker
docker --version  # Requires 20.10+

# Check Docker Compose
docker-compose --version  # Requires 1.29+

# Check Make
make --version

# Check you have sudo access
sudo -v
```

If missing, install:
```bash
# Docker (Debian/Ubuntu)
sudo apt update
sudo apt install docker.io docker-compose make

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Initial Configuration

1. **Clone the repository:**
```bash
git clone https://github.com/abd3l3li/Inception.git
cd Inception
```

2. **Configure domain in /etc/hosts:**
```bash
sudo nano /etc/hosts
```

Add:
```
127.0.0.1    login.42.fr
```

Replace `login` with your login.

3. **Create secrets directory and files:**
```bash
mkdir -p secrets
```

Create three password files:
```bash
echo "strong_db_password_here" > secrets/db_user_password.txt
echo "strong_admin_password" > secrets/wp_admin_password.txt
echo "strong_user_password" > secrets/wp_user_password.txt
```

Set restrictive permissions:
```bash
chmod 600 secrets/*.txt
```

4. **Configure environment variables:**

Edit `srcs/.env`:
```bash
# Database
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

# Domain
DOMAIN_NAME=login.42.fr

# WordPress Admin (username must NOT contain "admin")
WP_ADMIN_USER=your_login
WP_ADMIN_EMAIL=your_email@example.com

# WordPress Regular User
WP_USER=user
WP_USER_EMAIL=user@example.com
```

5. **Update volume paths in docker-compose.yml:**

If your username is different, update:
```yaml
volumes:
  mariadb_data:
    driver_opts:
      device: /home/YOUR_LOGIN/data/mariadb
  wordpress_data:
    driver_opts:
      device: /home/YOUR_LOGIN/data/wordpress
```

6. **Update Makefile:**

Change the `DATA_DIR` variable:
```makefile
DATA_DIR = /home/YOUR_LOGIN/data
```

## Building and Launching

### Using Makefile (Recommended)
```bash
# Build and start everything
make

# Stop services
make down

# Remove containers and images (keeps data)
make clean

# Full cleanup (removes data directories too)
make fclean

# Rebuild from scratch
make re

# Showing all the make commands
make help
```

### What make does:
```bash
# make = make all = make up
# which does:
mkdir -p /home/login/data/mariadb
mkdir -p /home/login/data/wordpress
docker-compose -f srcs/docker-compose.yml up -d --build
```

## Managing Containers and Volumes

### Container Management

**List running containers:**
```bash
docker ps
```

**List all containers (including stopped):**
```bash
docker ps -a
```

**Start a stopped container:**
```bash
docker start <container_name>
```

**Stop a running container:**
```bash
docker stop <container_name>
```

**Restart a container:**
```bash
docker restart <container_name>
```

**Remove a container:**
```bash
docker rm <container_name>
```

**Execute command in container:**
```bash
docker exec -it nginx sh
docker exec -it wordpress bash
docker exec -it mariadb bash
```

**View container logs:**
```bash
docker logs nginx
docker logs -f wordpress  # Follow logs in real-time
docker logs --tail 50 mariadb  # Last 50 lines
```

**Inspect container details:**
```bash
docker inspect nginx
```

### Volume Management

**List volumes:**
```bash
docker volume ls
```

**Inspect volume:**
```bash
docker volume inspect srcs_mariadb_data
```

**Remove unused volumes:**
```bash
docker volume prune
```

**Remove specific volume:**
```bash
docker volume rm srcs_mariadb_data
```

### Image Management

**List images:**
```bash
docker images
```

**Remove image:**
```bash
docker rmi inception-nginx
```

**Remove all unused images:**
```bash
docker image prune -a
```

**Rebuild specific service:**
```bash
docker-compose -f srcs/docker-compose.yml build --no-cache nginx
```

### Network Management

**List networks:**
```bash
docker network ls
```

**Inspect network:**
```bash
docker network inspect srcs_inception
```

**View network connections:**
```bash
docker network inspect srcs_inception | grep -A 5 Containers
```

## Data Storage and Persistence

### Data Location

All persistent data is stored on the host machine at:
```
/home/login/data/
├── mariadb/          # Database files
│   ├── aria_log_control
│   ├── ib_buffer_pool
│   ├── ibdata1
│   ├── mysql/        # System database
│   └── wordpress/    # WordPress database
└── wordpress/        # WordPress files
    ├── wp-admin/
    ├── wp-content/
    ├── wp-includes/
    └── wp-config.php
```

### How Persistence Works

**docker-compose.yml configuration:**
```yaml
services:
  mariadb:
    volumes:
      - mariadb_data:/var/lib/mysql

volumes:
  mariadb_data:
    driver: local
    driver_opts:
      device: /home/login/data/mariadb
      o: bind
      type: none
```

This creates a **bind mount**:
- Container path: `/var/lib/mysql`
- Host path: `/home/login/data/mariadb`
- Changes in container immediately appear on host and vice versa

### Accessing Data

**View database files:**
```bash
ls -la /home/login/data/mariadb/
```

**View WordPress files:**
```bash
ls -la /home/login/data/wordpress/
```

**Edit WordPress files directly:**
```bash
nano /home/login/data/wordpress/wp-config.php
```

Changes take effect immediately (no container restart needed for file changes).

### Data Backup

**Backup everything:**
```bash
sudo tar -czf inception-backup-$(date +%Y%m%d).tar.gz /home/login/data/
```

**Backup only database:**
```bash
sudo tar -czf db-backup.tar.gz /home/login/data/mariadb/
```

### Data Restore

**From filesystem backup:**
```bash
make down
sudo rm -rf /home/login/data/*
sudo tar -xzf inception-backup-20241222.tar.gz -C /
sudo chown -R 999:999 /home/login/data/mariadb
sudo chown -R 33:33 /home/login/data/wordpress
make
```

## Development Workflow

### Making Changes to Services

**1. Modify Dockerfile or configuration:**
```bash
nano srcs/requirements/nginx/default.conf
```

**2. Rebuild and restart:**
```bash
make down
make
```

Or rebuild specific service:
```bash
docker-compose -f srcs/docker-compose.yml build nginx
docker-compose -f srcs/docker-compose.yml up -d nginx
```

```

**Network debugging:**
```bash
# From wordpress container, test connection to mariadb
docker exec wordpress ping -c 3 mariadb
docker exec wordpress nc -zv mariadb 3306
```

**Check port bindings:**
```bash
docker port nginx
```

**Monitor resource usage:**
```bash
docker stats
```

## Project Structure Explained
```
inception/
├── Makefile                    # Build automation
├── README.md                   # Project overview
├── USER_DOC.md                 # End-user guide
├── DEV_DOC.md                  # This file
├── .gitignore                  # Git exclusions
├── secrets/                    # Credentials (not in git)
│   ├── db_user_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── docker-compose.yml      # Orchestration config
    ├── .env                    # Environment variables
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile      # Image definition
        │   └── setup.sh        # Init script
        ├── nginx/
        │   ├── Dockerfile
        │   └── default.conf    # Server config
        └── wordpress/
            ├── Dockerfile
            └── setup.sh        # Install script
```

### Key Files

**docker-compose.yml:** Defines services, networks, volumes, and dependencies

**Dockerfile:** Instructions to build each container image

**.env:** Non-sensitive configuration (usernames, database name, domain)

**secrets/*.txt:** Sensitive data (passwords)

**setup.sh:** Initialization scripts that run when containers start

## Advanced Commands

### Clean Docker System
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Nuclear option (removes everything)
docker system prune -a --volumes
```



> [!NOTE]
> - if you changed the published port, add it to the wp-config.php file as well
> - e.g. define('WP_HOME','https://${USER}.42.fr:8443');
> - e.g. define('WP_SITEURL','https://${USER}.42.fr:8443');
> - replace 8443 with the new port number.

