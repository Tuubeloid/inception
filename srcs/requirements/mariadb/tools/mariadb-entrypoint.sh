#!/bin/sh

log() {
  printf "[TRACE] %s\n" "$1"
}

# Ensure required environment variables are set
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  log "[ERROR] Missing required environment variables!"
  exit 1
fi

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
  log "🔑 Initializing MariaDB Data Directory..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1
  
  log "✅ Database Directory Initialized"

  log "🔥 Starting MariaDB temporarily to apply setup..."
  mysqld --user=mysql --bootstrap <<EOF
DROP DATABASE IF EXISTS $MYSQL_DATABASE;
CREATE DATABASE $MYSQL_DATABASE;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

  log "✅ Database Setup Completed"
else
  log "✅ Database Already Initialized — Skipping Setup"
fi

log "🚀 Starting MariaDB service..."
exec mysqld --user=mysql --console
