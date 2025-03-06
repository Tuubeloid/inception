FROM alpine:3.20.5 

# Update and install necessary packages
RUN apk update && apk add --no-cache nginx openssl curl

# Create necessary directories for SSL certificates
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate SSL certificates for NGINX (self-signed certificate)
RUN openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt -days 365 -nodes -subj "/C=FI/L=Helsinki/O=Hive/OU=Student/CN=tvalimak.42.fr"

# Set the correct permissions for the SSL certificate and key
RUN chmod 644 /etc/ssl/certs/selfsigned.crt && chmod 600 /etc/ssl/private/selfsigned.key

# Copy NGINX configuration file
COPY conf/nginx.conf /etc/nginx/
RUN chmod 644 /etc/nginx/nginx.conf

# Copy entrypoint script for custom configuration at startup
COPY tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

# Debug Line 🔥 (temporary)
RUN ls -la /usr/local/bin/ && ls -la /etc/ssl/certs/ && ls -la /etc/ssl/private/

# Expose port 443 for HTTPS
EXPOSE 443

# Healthcheck to verify that NGINX is serving over HTTPS
HEALTHCHECK --interval=5s --timeout=3s --retries=10 CMD curl -kf https://localhost || exit 1

# Use the entrypoint script to configure NGINX at runtime
ENTRYPOINT ["sh", "/usr/local/bin/nginx-entrypoint.sh"]
