# User Documentation

## What Services Are Provided

This infrastructure provides a complete WordPress website with the following services:

- **Website** - A WordPress content management system accessible via HTTPS
- **Database** - MariaDB storing all website data (posts, pages, users, settings)
- **Web Server** - NGINX handling secure connections and serving content

All services run automatically in Docker containers and restart on system reboot.

## Starting the Project

To start all services:
```bash
make
```

This command will:
1. Create data directories if they don't exist
2. Build Docker images if needed
3. Start all containers in the background

Wait 10-15 seconds for services to fully initialize.

## Stopping the Project

To stop all services:
```bash
make down
```

This stops containers but preserves your data and images.

## Accessing the Website

### Main Website

Open your browser and navigate to:
```
https://abel-baz.42.fr
```

**First visit:** Your browser will show a security warning because the SSL certificate is self-signed. This is normal for local development.

To proceed:
1. Click "Advanced"
2. Click "Proceed to abel-baz.42.fr" (or similar option depending on browser)

### Administration Panel

To access the WordPress admin dashboard:
```
https://abel-baz.42.fr/wp-admin
```

Log in with your administrator credentials.

## Managing Credentials

### Location of Credentials

Passwords are stored in the `secrets/` directory:
```
secrets/
├── db_user_password.txt       # Database password
├── wp_admin_password.txt      # WordPress admin password
└── wp_user_password.txt       # WordPress regular user password
```

Usernames and emails are in `srcs/.env`:
```
WP_ADMIN_USER=login          # Admin username
WP_ADMIN_EMAIL=login@example.com
WP_USER=user                     # Regular user username
WP_USER_EMAIL=user@example.com
```

### Viewing Credentials

To view a password:
```bash
cat secrets/db_user_password.txt
```

### Changing Passwords

1. Stop the services:
```bash
make down
```

2. Edit the password file:
```bash
echo "new_password" > secrets/wp_admin_password.txt
```

3. For password changes to take effect, you need to rebuild:
```bash
make fclean
make
```

**Warning:** `make fclean` deletes all data. For production, change passwords through WordPress admin panel instead.

## Checking Service Status

### Check All Containers
```bash
docker ps -a
```

You should see three running containers:
- `nginx` - Status should be "Up"
- `wordpress` - Status should be "Up"
- `mariadb` - Status should be "Up"

### Check Specific Service
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Check Data Persistence
```bash
ls -la /home/abel-baz/data/mariadb/
ls -la /home/abel-baz/data/wordpress/
```

Both directories should contain files. If empty, containers haven't written data yet.

## Troubleshooting

### Website Not Loading

1. Check if containers are running: `docker ps`
2. If no containers, start them: `make`
3. Check logs: `docker logs nginx`

### "502 Bad Gateway" Error

Wait 10-15 seconds and refresh. Services need time to start. If persists after 30 seconds:
```bash
make down
make
```

### "Error Establishing Database Connection"

MariaDB is still initializing. Wait 15 seconds and refresh. If persists:
```bash
docker logs mariadb
```

Look for errors in the output.

### Forgot Admin Password

Passwords are in `secrets/wp_admin_password.txt`:
```bash
cat secrets/wp_admin_password.txt
```

### Container Keeps Restarting

Check logs for the problematic container:
```bash
docker ps -a
docker logs <container_name>
```

Common fix:
```bash
make fclean
make
```

## Regular Maintenance

### Viewing Logs

To see real-time logs:
```bash
docker logs -f wordpress
```

Press `Ctrl+C` to stop viewing.

### Backing Up Data

Your data is in `/home/abel-baz/data/`:
```bash
sudo tar -czf backup.tar.gz /home/abel-baz/data/
```

### Restoring from Backup
```bash
make down
sudo rm -rf /home/abel-baz/data/*
sudo tar -xzf backup.tar.gz -C /
make
```

## System Requirements

- At least 2GB free disk space
- At least 1GB free RAM
- Port 443 must be available (not used by other services)

## Security Notes

- Default setup uses self-signed SSL certificates (development only)
- Change default passwords in production environments
- Passwords are stored in plain text files (use proper secrets management in production)
- Admin username should not contain "admin" for security