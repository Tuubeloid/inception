FROM alpine:3.20.5
RUN apk update && apk add --no-cache mariadb mariadb-client gettext
RUN mkdir -p /run/mysqld /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld
COPY ./conf/my.cnf /etc/mysql/
RUN chmod 644 /etc/mysql/my.cnf
COPY tools/init.sql /etc/mysql/
RUN chmod 644 /etc/mysql/init.sql
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh
EXPOSE 3306
ENTRYPOINT [ "sh", "/usr/local/bin/mariadb-entrypoint.sh" ]
