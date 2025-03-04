#!/bin/sh

log() {
  printf "[TRACE] %s\n" "$1"
}

# Environment Variable Check
if [ -z "$DATABASE_NAME" ] || [ -z "$DATABASE_USER" ] || [ -z "$DATABASE_PASS" ]; then
  log "[ERROR] Missing environment variables!"
  exit 1
fi

# Initialize Database Only If It Doesn't Exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
  log "🔑 Initializing MariaDB Data Directory..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1
  
  log "✅ Database Directory Initialized"

  log "🔥 Starting MariaDB temporarily to apply setup..."
  mysqld --user=mysql --bootstrap <<EOF
DROP DATABASE IF EXISTS $DATABASE_NAME;
CREATE DATABASE $DATABASE_NAME;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DATABASE_PASS';
CREATE USER IF NOT EXISTS '$DATABASE_USER'@'%' IDENTIFIED BY '$DATABASE_PASS';
GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$DATABASE_USER'@'%';
FLUSH PRIVILEGES;
EOF
  log "✅ Database Setup Completed"
else
  log "✅ Database Already Initialized — Skipping Setup"
fi

log "🚀 Starting MariaDB service..."
exec mysqld --user=mysql --console
