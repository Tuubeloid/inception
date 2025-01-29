FROM debian:buster
RUN apt-get update && apt-get install -y mariadb-server
COPY db1.sql /docker-entrypoint-initdb.d/
CMD ["/usr/bin/mysqld_safe"]
