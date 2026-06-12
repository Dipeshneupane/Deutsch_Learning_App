#!/bin/sh
set -eu

cat > /srv/config.js <<EOF
window.__APP_CONFIG__ = {
  apiBaseUrl: "${API_BASE_URL:-http://localhost:8080/api/v1}",
};
EOF

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
