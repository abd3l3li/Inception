# 🐳 Inception

*This project has been created as part of the 42 curriculum by abel-baz.*

---
![IMG](https://github.com/user-attachments/assets/f0259504-98fc-4408-a681-2b65cdb63f42)
---

## Description

**Inception** is a System Administration project that involves setting up a small infrastructure using Docker and Docker Compose. The goal is to virtualize multiple Docker images by creating them within a personal virtual machine.

The infrastructure consists of three core services:
- **NGINX** - Web server with TLSv1.2/1.3 handling HTTPS on port 443
- **WordPress** - Content management system with PHP-FPM
- **MariaDB** - Database server for WordPress

Each service runs in a dedicated container, built from custom Dockerfiles. Services communicate through a private Docker network, and data persists through volumes mounted to the host filesystem at `/home/login/data/`.

---

## Instructions

### Prerequisites

- Virtual machine running Linux
- Docker (version 20.10+)
- Docker Compose (version 1.29+)
- Make
- sudo privileges

### Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/abd3l3li/Inception.git
cd Inception
```

2. **Configure domain name**
```bash
sudo nano /etc/hosts
```
Add this line:
```
127.0.0.1    login.42.fr
```

3. **Create secret files**
```bash
mkdir -p secrets
echo "your_database_password" > secrets/db_user_password.txt
echo "your_admin_password" > secrets/wp_admin_password.txt
echo "your_user_password" > secrets/wp_user_password.txt
chmod 600 secrets/*.txt
```

4. **Configure environment**

Edit and add `srcs/.env`:
```
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
DOMAIN_NAME=login.42.fr
WP_ADMIN_USER=login
WP_ADMIN_EMAIL=login@example.com
WP_USER=user
WP_USER_EMAIL=user@example.com
```

5. **Build and start**
```bash
make
```

6. **Access the site**

Open browser: `https://login.42.fr`

(Accept the self-signed certificate warning)

### Commands
```bash
make        # Build and start
make down   # Stop services
make clean  # Remove containers and images
make fclean # Full cleanup including data
make re     # Rebuild from scratch
make help   # Show all the make commands
```

---

## Project Description

**Docker Usage:** Provides isolation, reproducibility, and portability. Each service runs in its own container sharing the host OS kernel.

**Services:**
- NGINX: Entry point on port 443 with TLS, proxies to WordPress
- WordPress: PHP-FPM on port 9000, managed via WP-CLI
- MariaDB: Database on port 3306 with persistent storage

**Design Choices:** Debian Bookworm for stability, custom Dockerfiles for control, Docker secrets for security, bind mounts for data persistence at `/home/login/data/`.

**Virtual Machines vs Docker:** VMs provide full OS isolation with heavy resource usage and slow boot times. Docker shares the host kernel, uses minimal resources, and starts instantly. Docker is ideal for this project due to efficiency and rapid development cycles.

**Secrets vs Environment Variables:** Docker secrets store sensitive data encrypted and mount as files in `/run/secrets/`. Environment variables are visible in container inspection and logs. Secrets provide better security for passwords.

**Docker Network vs Host Network:** Bridge networks isolate containers with DNS resolution between them. Host network shares the host's network stack. Bridge networks provide security through isolation while allowing controlled communication.

**Docker Volumes vs Bind Mounts:** Volumes are Docker-managed storage, bind mounts use specific host paths. This project uses bind mounts (`/home/login/data/`) for easy access, backup, and subject compliance.

## Resources

- Dockerfile: https://docs.docker.com/reference/dockerfile/
- Tutorials:
    - https://youtu.be/DQdB7wFEygo?si=vvv091_LkqOoIESe
    - https://youtu.be/b0HMimUb4f0?si=3fzE6LuTYqY3kbr8
    - https://youtube.com/playlist?list=PLTk5ZYSbd9Mg51szw21_75Hs1xUpGObDm&si=wAg_jLCHTwj0pq2H
    - https://youtu.be/DM65_JyGxCo?si=YyAzsYblHzyPwLuC
    - https://youtu.be/67Kfsmy_frM?si=NtCUEHqXvoVz_uWw
- Practice the commands before using docker compose.
- AI were used for enhancing the scripts and for double checking, In addition of setupping the Docs

  [-] You clould also check the subject file from (HERE)[https://github.com/abd3l3li/Inception/blob/master/inception.pdf].

## What's next?
- For getting deep in the project concepts and usage, check:
  - **[USER_DOC](https://github.com/abd3l3li/Inception/blob/master/USER_DOC.md)**
  - **[DEV_DOC](https://github.com/abd3l3li/Inception/blob/master/DEV_DOC.md)**
## Author

__abel-baz - 42 Network__
