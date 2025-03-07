FROM alpine:3.20.5
RUN apk update && apk add --no-cache nginx openssl curl
COPY ./tools/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh
EXPOSE 443
ENTRYPOINT [ "sh", "/usr/local/bin/mariadb-entrypoint.sh" ]
