CREATE DATABASE IF NOT EXISTS mydatabase ;
CREATE USER IF NOT EXISTS 'myuser'@'%' IDENTIFIED BY 'mysecurepassword' ;
GRANT ALL PRIVILEGES ON mydatabase.* TO 'myuser'@'%' ;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'pass' ;
FLUSH PRIVILEGES;
