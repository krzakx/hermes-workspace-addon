#!/usr/bin/env bash
# HAOS Add-on entrypoint for Hermes Workspace
# Starts nginx reverse proxy + Node.js server
set -e

echo "======================================"
echo "  Hermes Workspace Add-on starting"
echo "======================================"

# Read addon options using python3
if [[ -f /data/options.json ]]; then
    eval "$(python3 << 'PYEOF'
import json
d = json.load(open('/data/options.json'))
print(f'export HERMES_API_URL="{d.get("hermes_agent_url", "http://172.30.32.1:8642")}"')
print(f'export HERMES_DASHBOARD_URL="{d.get("hermes_dashboard_url", "http://172.30.32.1:9119")}"')
print(f'export HERMES_API_TOKEN="{d.get("hermes_api_token", "")}"')
print(f'export HERMES_PASSWORD="{d.get("hermes_password", "")}"')
print(f'export COOKIE_SECURE="{str(d.get("cookie_secure", False)).lower()}"')
print(f'export TRUST_PROXY="{str(d.get("trust_proxy", False)).lower()}"')
PYEOF
)"
else
    export HERMES_API_URL="${HERMES_AGENT_URL:-http://172.30.32.1:8642}"
    export HERMES_DASHBOARD_URL="${HERMES_DASHBOARD_URL:-http://172.30.32.1:9119}"
    export HERMES_API_TOKEN="${HERMES_API_TOKEN:-}"
    export HERMES_PASSWORD="${HERMES_PASSWORD:-}"
    export COOKIE_SECURE="${COOKIE_SECURE:-false}"
    export TRUST_PROXY="${TRUST_PROXY:-false}"
fi

# Workspace directories
export HERMES_HOME="/config/.hermes"
export HERMES_WORKSPACE_DIR="/workspace"
export PORT="3000"
export HOST="0.0.0.0"

# Ensure directories exist
mkdir -p "${HERMES_HOME}"
mkdir -p "${HERMES_WORKSPACE_DIR}"

echo "Hermes Agent URL: ${HERMES_API_URL}"
echo "Hermes Dashboard URL: ${HERMES_DASHBOARD_URL}"
echo "Cookie Secure: ${COOKIE_SECURE}"
echo "Trust Proxy: ${TRUST_PROXY}"
echo "HERMES_HOME: ${HERMES_HOME}"
echo "Workspace Dir: ${HERMES_WORKSPACE_DIR}"

# Start nginx reverse proxy (listens on 8080, proxies to 3000)
nginx -g 'daemon off;' &

# The app is at /app
cd /app

# Start the Next.js server
exec node --max-old-space-size=2048 server-entry.js
