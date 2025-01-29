To configure the domain name:
1. Open the /etc/hosts file (use sudo if necessary).
2. Add the following line:
   127.0.0.1    yourlogin.42.fr
3. Save and close the file.

To run mysql container:
4. sudo docker run --env-file /media/sf_shared/srcs/.env -v my-volume:/var/lib/mysql mysql
