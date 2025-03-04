#!/bin/sh

log() {
  printf "[TRACE] %s\n" "$1"
}

if [ -z "$DOMAIN_NAME" ] || [ -z "$SSL_CERT_PATH" ] || [ -z "$SSL_KEY_PATH" ]; then
  log "[ERROR] Missing environment variables!"
  exit 1
fi

log "🔑 Checking if SSL certificates already exist..."
if [ ! -f "$SSL_CERT_PATH" ] || [ ! -f "$SSL_KEY_PATH" ]; then
  log "Generating self-signed SSL certificate and private key..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out "$SSL_CERT_PATH" -keyout "$SSL_KEY_PATH" \
  -subj "/C=FI/L=Helsinki/O=Hive/OU=Student/CN=$DOMAIN_NAME" > /dev/null 2>&1
  
  log "✅ SSL Certificates Generated"
else
  log "✅ SSL certificates already exist — skipping generation."
fi

log "🔄 Replacing placeholders in nginx.conf with environment variables..."
sed -i "s|ssl_cert_path|$SSL_CERT_PATH|g" /etc/nginx/nginx.conf
sed -i "s|ssl_key_path|$SSL_KEY_PATH|g" /etc/nginx/nginx.conf
sed -i "s|domain_name|$DOMAIN_NAME|g" /etc/nginx/nginx.conf

log "🚀 Starting Nginx service..."
nginx -g "daemon off;"

