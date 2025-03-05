FROM alpine:3.20.5

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /run/mysqld /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld

COPY ./conf/my.cnf /etc/mysql/
RUN chmod 644 /etc/mysql/my.cnf

COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

EXPOSE 3306

# Install curl for healthcheck
RUN apk add --no-cache curl

# Healthcheck to see if MariaDB is alive
HEALTHCHECK CMD mysqladmin ping -h localhost -u$$MYSQL_USER -p$$MYSQL_PASSWORD || exit 1

ENTRYPOINT [ "sh", "/usr/local/bin/mariadb-entrypoint.sh" ]
