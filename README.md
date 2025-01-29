To configure the domain name:
1. Open the /etc/hosts file (use sudo if necessary).
2. Add the following line:
   127.0.0.1    yourlogin.42.fr
3. Save and close the file.

To run mysql container:
4. sudo docker run --env-file /media/sf_shared/srcs/.env -v my-volume:/var/lib/mysql mysql

For mariadb:
export db_name=mydatabase
export db_user=myuser
export db_pwd=mysecurepassword

echo "CREATE DATABASE IF NOT EXISTS $db_name ;" > db1.sql
echo "CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_pwd' ;" >> db1.sql
echo "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%' ;" >> db1.sql
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '12345' ;" >> db1.sql
echo "FLUSH PRIVILEGES;" >> db1.sql
