FROM alpine:3.20.5

RUN apk update && apk add --no-cache nginx openssl

COPY conf/nginx.conf /etc/nginx/
RUN chmod 644 /etc/nginx/nginx.conf

COPY tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

# Debug Line 🔥 (temporary)
RUN ls -la /usr/local/bin/

EXPOSE 443

ENTRYPOINT ["sh", "/usr/local/bin/nginx-entrypoint.sh"]
