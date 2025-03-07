FROM alpine:3.20.5
RUN apk update && apk add --no-cache mariadb mariadb-client mariadb-common bash
RUN mkdir -p /var/run/mysqld && \
	mkdir -p /var/log/mysql && \
	mkdir -p /var/lib/mysql && \
	chown -R mysql:mysql /var/run/mysqld && \
	chown -R mysql:mysql /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql
COPY ./conf/my.cnf /etc/mysql/
RUN chmod 644 /etc/mysql/my.cnf
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh
EXPOSE 3306

ENTRYPOINT [ "sh", "/usr/local/bin/mariadb-entrypoint.sh" ]
