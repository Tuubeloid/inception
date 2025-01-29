To configure the domain name:
1. Open the /etc/hosts file (use sudo if necessary).
2. Add the following line:
   127.0.0.1    yourlogin.42.fr
3. Save and close the file.

4. To run mysql container:
5. sudo docker run --env-file /media/sf_shared/srcs/.env -v my-volume:/var/lib/mysql mysql

6. For mariadb:
7. export db_name=mydatabase
8. export db_user=myuser
9. export db_pwd=mysecurepassword

10. echo "CREATE DATABASE IF NOT EXISTS $db_name ;" > db1.sql
11. echo "CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_pwd' ;" >> db1.sql
12. echo "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%' ;" >> db1.sql
13. echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '12345' ;" >> db1.sql
14. echo "FLUSH PRIVILEGES;" >> db1.sql
