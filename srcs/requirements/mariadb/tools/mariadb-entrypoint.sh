#!/bin/sh

log() {
  printf "[TRACE] %s\n" "$1"
}

# Ensure required environment variables are set
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  log "[ERROR] Missing required environment variables!"
  exit 1
fi

# configure server to be reachable by other containers on the first run
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
	mysql --socket=/var/run/mysqld/mysqld.sock -uroot <<-EOF
	    FLUSH PRIVILEGES;
	    ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
	    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
	    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
	    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
	    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
	    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
	    FLUSH PRIVILEGES;
	EOF


	echo "Shutting down temporary MariaDB..."
	mysqladmin shutdown --socket=/var/run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}"
fi


log "🚀 Starting MariaDB service..."
exec mysqld --user=mysql

