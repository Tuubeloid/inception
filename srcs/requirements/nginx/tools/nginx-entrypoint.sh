#!/bin/sh

echo "[DEBUG] nginx-entrypoint.sh is running"

log() {
  printf "[TRACE] %s\n" "$1"
}

if [ -z "$DOMAIN_NAME" ] || [ -z "$SSL_CERT_PATH" ] || [ -z "$SSL_KEY_PATH" ]; then
  log "[ERROR] Missing environment variables!"
  exit 1
fi

log "🔑 Checking if SSL certificates exist..."
if [ ! -f "$SSL_CERT_PATH" ] || [ ! -f "$SSL_KEY_PATH" ]; then
  log "🚨 SSL certificates missing — generating new ones..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$SSL_KEY_PATH" -out "$SSL_CERT_PATH" \
  -subj "/C=FI/L=Helsinki/O=Hive/OU=Student/CN=$DOMAIN_NAME"
  log "✅ SSL Certificates Generated"
else
  log "✅ SSL certificates found — skipping generation."
fi

# Fix permissions in case they were modified
log "🔒 Fixing SSL certificates permissions..."
chmod 644 "$SSL_CERT_PATH" && chmod 600 "$SSL_KEY_PATH"

# Replace placeholders in nginx.conf with env variables
log "🔄 Replacing placeholders in nginx.conf with environment variables..."
sed -i "s|ssl_cert_path|$SSL_CERT_PATH|g" /etc/nginx/nginx.conf
sed -i "s|ssl_key_path|$SSL_KEY_PATH|g" /etc/nginx/nginx.conf
sed -i "s|domain_name|$DOMAIN_NAME|g" /etc/nginx/nginx.conf

# Debug list 🔥
log "📄 Listing SSL certificate files for debug:"
ls -la "$SSL_CERT_PATH" "$SSL_KEY_PATH"

log "🚀 Starting Nginx service..."
nginx -g "daemon off;"

