#!/usr/bin/env bash
# HAOS Add-on entrypoint for Hermes Workspace
# Reads addon options from /data/options.json and starts the Next.js server
set -e

echo "======================================"
echo "  Hermes Workspace Add-on starting"
echo "======================================"

# Read addon options (HA injects options as __OPTION_NAME env vars too)
# But we'll also read from /data/options.json for clarity
if [[ -f /data/options.json ]]; then
    export HERMES_API_URL=$(jq -r '.hermes_agent_url // "http://172.30.32.1:8642"' /data/options.json)
    export HERMES_DASHBOARD_URL=$(jq -r '.hermes_dashboard_url // "http://172.30.32.1:9119"' /data/options.json)
    export HERMES_API_TOKEN=$(jq -r '.hermes_api_token // ""' /data/options.json)
    export HERMES_PASSWORD=$(jq -r '.hermes_password // ""' /data/options.json)
    export COOKIE_SECURE=$(jq -r '.cookie_secure // true' /data/options.json)
    export TRUST_PROXY=$(jq -r '.trust_proxy // true' /data/options.json)
else
    # Fallback to env vars (set by HA from options)
    export HERMES_API_URL="${__HERMES_AGENT_URL:-http://172.30.32.1:8642}"
    export HERMES_DASHBOARD_URL="${__HERMES_DASHBOARD_URL:-http://172.30.32.1:9119}"
    export HERMES_API_TOKEN="${__HERMES_API_TOKEN:-}"
    export HERMES_PASSWORD="${__HERMES_PASSWORD:-}"
    export COOKIE_SECURE="${__COOKIE_SECURE:-true}"
    export TRUST_PROXY="${__TRUST_PROXY:-true}"
fi

# Convert boolean strings to proper values
export COOKIE_SECURE=$(echo "${COOKIE_SECURE}" | tr '[:upper:]' '[:lower:]')
export TRUST_PROXY=$(echo "${TRUST_PROXY}" | tr '[:upper:]' '[:lower:]')

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

# The upstream image has the app at /usr/src/app
cd /usr/src/app

# Start the Next.js server (standalone output)
# Uses node directly since it's a standalone build
exec node server.js