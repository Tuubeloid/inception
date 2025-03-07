#!/bin/sh

log() {
  printf "[TRACE] %s\n" "$1"
}

# Ensure required environment variables are set
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  log "[ERROR] Missing required environment variables!"
  exit 1
fi

# Check if the database directory exists; if not, initialize
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Installing MySQL..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	echo "Starting MariaDB temporarily..."
	mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &

	echo "Waiting for MariaDB to start..."
	until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
		sleep 2
	done

	echo "Setting up database and users..."

	# Use `envsubst` to replace placeholders in `init.sql`
	envsubst < /etc/mysql/init.sql > /tmp/init.sql

	# Execute the modified SQL script
	mysql --socket=/var/run/mysqld/mysqld.sock -uroot < /tmp/init.sql

	echo "Shutting down temporary MariaDB..."
	mysqladmin shutdown --socket=/var/run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}"
fi

log "🚀 Starting MariaDB service..."
exec mysqld --user=mysql

