#!/bin/sh
set -e

# Helper to run forgejo CLI as git user
forgejo_cli() {
  sudo -u git forgejo --config /data/gitea/conf/app.ini "$@"
}

# 1. Wait for PostgreSQL
echo "[forgejo] waiting for postgres..."
until PGPASSWORD="${FORGEJO_DB_PASSWD}" psql -h postgres -U "${FORGEJO_DB_USER}" -d "${FORGEJO_DB_NAME}" -c "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done
echo "[forgejo] postgres is ready"

# 2. Run database migrations
echo "[forgejo] running DB migrations..."
forgejo_cli migrate

# 3. Add TLS certificate to system trust store
if [ -d /etc/certs ]; then
  echo "[forgejo] adding TLS certificates to trust store..."
  cp /etc/certs/*.pem /usr/local/share/ca-certificates/vcc.crt 2>/dev/null || true
  update-ca-certificates || true
fi

# 4. Create admin user if not exists
echo "[forgejo] checking admin user..."
if ! forgejo_cli admin user list | grep -q "${FORGEJO_ADMIN_USER}"; then
  echo "[forgejo] creating admin user..."
  forgejo_cli admin user create \
    --username "${FORGEJO_ADMIN_USER}" \
    --password "${FORGEJO_ADMIN_PASS}" \
    --email "${FORGEJO_ADMIN_EMAIL}" \
    --admin
fi

# 5. Start Forgejo in background
echo "[forgejo] starting forgejo..."
/bin/s6-svscan /etc/s6 &
S6_PID=$!

# 6. Wait for Forgejo HTTP to be ready
echo "[forgejo] waiting for HTTP..."
until curl -sf http://127.0.0.1:3200/api/healthz >/dev/null; do
  sleep 2
done
echo "[forgejo] HTTP is ready"

# 7. Wait for Dex to be ready
echo "[forgejo] waiting for Dex..."
until curl -sf http://dex:5556/.well-known/openid-configuration >/dev/null; do
  sleep 2
done
echo "[forgejo] Dex is ready"

# 8. Setup OAuth provider if not exists
echo "[forgejo] checking OAuth provider..."
if ! forgejo_cli admin auth list | grep -q "Dex"; then
  echo "[forgejo] adding Dex OAuth provider..."
  forgejo_cli admin auth add-oauth \
    --name "Dex" \
    --provider openidConnect \
    --key "${DEX_CLIENT_ID}" \
    --secret "${DEX_CLIENT_SECRET}" \
    --auto-discover-url "https://auth.vcc.internal/.well-known/openid-configuration"
fi

echo "[forgejo] ready"
wait $S6_PID
