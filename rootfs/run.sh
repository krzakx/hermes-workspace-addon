#!/usr/bin/env bash
# HAOS Add-on entrypoint for Hermes Workspace
set -e

echo "======================================"
echo "  Hermes Workspace Add-on starting"
echo "======================================"

if [[ -f /data/options.json ]]; then
    HERMES_API_URL=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(d.get('hermes_agent_url','http://172.30.32.1:8642'))")
    HERMES_DASHBOARD_URL=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(d.get('hermes_dashboard_url','http://172.30.32.1:9119'))")
    HERMES_API_TOKEN=*** -c "import json; d=json.load(open('/data/options.json')); print(d.get('hermes_api_token',''))")
    HERMES_PASSWORD=*** -c "import json; d=json.load(open('/data/options.json')); print(d.get('hermes_password',''))")
    COOKIE_SECURE=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(str(d.get('cookie_secure',False)).lower())")
    TRUST_PROXY=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(str(d.get('trust_proxy',False)).lower())")
    export HERMES_API_URL HERMES_DASHBOARD_URL HERMES_API_TOKEN HERMES_PASSWORD COOKIE_SECURE TRUST_PROXY
else
    export HERMES_API_URL="${HERMES_AGENT_URL:-http://172.30.32.1:8642}"
    export HERMES_DASHBOARD_URL="${HERMES_DASHBOARD_URL:-http://172.30.32.1:9119}"
    export HERMES_API_TOKEN=***    export HERMES_PASSWORD=***    export COOKIE_SECURE="${COOKIE_SECURE:-false}"
    export TRUST_PROXY="${TRUST_PROXY:-false}"
fi

export HERMES_HOME="/config/.hermes"
export HERMES_WORKSPACE_DIR="/workspace"
export PORT="3000"
export HOST="0.0.0.0"

mkdir -p "${HERMES_HOME}"
mkdir -p "${HERMES_WORKSPACE_DIR}"

echo "Hermes Agent URL: ${HERMES_API_URL}"
echo "Hermes Dashboard URL: ${HERMES_DASHBOARD_URL}"
echo "Cookie Secure: ${COOKIE_SECURE}"
echo "Trust Proxy: ${TRUST_PROXY}"

cd /app
exec node --max-old-space-size=2048 server-entry.js
