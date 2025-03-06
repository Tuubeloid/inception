FROM alpine:3.20.5

# Update and install necessary packages
RUN apk update && apk add --no-cache nginx openssl curl

# Generate SSL certificates for NGINX
RUN openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Company/OU=Department/CN=localhost"

# Copy NGINX configuration file
COPY conf/nginx.conf /etc/nginx/
RUN chmod 644 /etc/nginx/nginx.conf

# Copy entrypoint script for custom configuration at startup
COPY tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

# Debug Line 🔥 (temporary)
RUN ls -la /usr/local/bin/

# Expose port 443 for HTTPS
EXPOSE 443

# Healthcheck to verify that NGINX is serving over HTTPS
HEALTHCHECK --interval=5s --timeout=3s --retries=10 CMD curl -kf https://localhost || exit 1

# Use the entrypoint script to configure NGINX at runtime
ENTRYPOINT ["sh", "/usr/local/bin/nginx-entrypoint.sh"]
