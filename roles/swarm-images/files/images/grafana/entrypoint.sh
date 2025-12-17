#!/bin/sh
set -e

# 1. Wait for PostgreSQL
echo "[grafana] waiting for postgres..."
until PGPASSWORD="${GF_DATABASE_PASSWORD}" psql -h postgres -U "${GF_DATABASE_USER}" -d "${GF_DATABASE_NAME}" -c "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done
echo "[grafana] postgres is ready"

# 2. Add TLS certificate to trust store
if [ -f /etc/certs/cert.pem ]; then
  echo "[grafana] adding TLS certificate..."
  cp /etc/certs/cert.pem /usr/local/share/ca-certificates/vcc.crt
  update-ca-certificates
fi

# 3. Wait for Dex
echo "[grafana] waiting for Dex..."
until curl -sf https://auth.vcc.internal/.well-known/openid-configuration >/dev/null 2>&1; do
  sleep 2
done
echo "[grafana] Dex is ready"

# 4. Set OAuth environment variables (exam requirement: use export)
export GF_AUTH_GENERIC_OAUTH_ENABLED=true
export GF_AUTH_GENERIC_OAUTH_NAME="Dex"
export GF_AUTH_GENERIC_OAUTH_CLIENT_ID="${GRAFANA_OAUTH_CLIENT_ID}"
export GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET="${GRAFANA_OAUTH_CLIENT_SECRET}"
export GF_AUTH_GENERIC_OAUTH_SCOPES="openid email profile"
export GF_AUTH_GENERIC_OAUTH_AUTH_URL="https://auth.vcc.internal/auth"
export GF_AUTH_GENERIC_OAUTH_TOKEN_URL="http://dex:5556/token"
export GF_AUTH_GENERIC_OAUTH_API_URL="http://dex:5556/userinfo"
export GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP=true
export GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH="contains(groups[*], 'admin') && 'Admin' || 'Editor'"
export GF_AUTH_GENERIC_OAUTH_ALLOW_ASSIGN_GRAFANA_ADMIN=true
export GF_AUTH_DISABLE_LOGIN_FORM=true

echo "[grafana] starting grafana..."
exec /run.sh "$@"
