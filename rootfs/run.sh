#!/usr/bin/env bash
# HAOS Add-on entrypoint for Hermes Workspace
# Reads addon options from /data/options.json and starts the Next.js server
set -e

echo "======================================"
echo "  Hermes Workspace Add-on starting"
echo "======================================"

# Read addon options using python3 (jq not available in slim image)
if [[ -f /data/options.json ]]; then
    export HERMES_API_URL=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(d.get('hermes_agent_url','http://172.30.32.1:8642'))")
    export HERMES_DASHBOARD_URL=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(d.get('hermes_dashboard_url','http://172.30.32.1:9119'))")
    export HERMES_API_TOKEN=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(d.get('hermes_api_token',''))")
    export HERMES_PASSWORD=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(d.get('hermes_password',''))")
    export COOKIE_SECURE=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(str(d.get('cookie_secure', True)).lower())")
    export TRUST_PROXY=$(python3 -c "import json; d=json.load(open('/data/options.json')); print(str(d.get('trust_proxy', True)).lower())")
else
    # Fallback to env vars (set by HA from options)
    export HERMES_API_URL="${HERMES_AGENT_URL:-http://172.30.32.1:8642}"
    export HERMES_DASHBOARD_URL="${HERMES_DASHBOARD_URL:-http://172.30.32.1:9119}"
    export HERMES_API_TOKEN="${HERMES_API_TOKEN:-}"
    export HERMES_PASSWORD="${HERMES_PASSWORD:-}"
    export COOKIE_SECURE="${COOKIE_SECURE:-true}"
    export TRUST_PROXY="${TRUST_PROXY:-true}"
fi

# Workspace directories (persisted in /config which mounts to addon_configs)
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

# The app is at /app in our build
cd /app

# Start the Next.js server
exec node --max-old-space-size=2048 server-entry.js
