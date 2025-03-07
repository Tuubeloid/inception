-- Drop the database if it exists, then create a new one
DROP DATABASE IF EXISTS `${MYSQL_DATABASE}`;
CREATE DATABASE `${MYSQL_DATABASE}`;

-- Manually set the password for the root user
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Create the user if it doesn't already exist and set permissions
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON `${MYSQL_DATABASE}`.* TO '${MYSQL_USER}'@'%';

-- Apply changes
FLUSH PRIVILEGES;
