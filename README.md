# Hermes Workspace — HAOS Add-on

[![Open in Home Assistant](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=hermes-workspace&repository_url=https%3A%2F%2Fgithub.com%2Fkrzakx%2Fhermes-workspace-addon)

HAOS add-on for [Hermes Workspace](https://github.com/outsourc-e/hermes-workspace) — the native web workspace for Hermes Agent.

## Features

- 💬 **Chat** — Real-time SSE streaming, tool calls, multi-session, markdown
- 🧠 **Memory** — Browse, search, and edit agent memory
- 🧩 **Skills** — Browse 2000+ skills with marketplace, filters, origin badges
- 🔌 **MCP** — Full catalog + marketplace + sources
- 📁 **Files + Terminal** — Monaco editor + cross-platform PTY terminal
- 🎮 **Operations** — Multi-agent dashboard with profile presets
- 📡 **Conductor** — Mission dispatch + decomposition
- 👥 **Agent View** — Live agent panel with queue, history, usage
- 🐝 **Swarm Mode** — Persistent tmux-backed workers
- 🗄️ **Dashboard** — Sessions, model mix, cost ledger, attention card
- 🎨 **Themes** — Hermes, Nous, Bronze, Slate, Mono (light + dark)
- 📱 **PWA** — Install as native-feeling app

## Prerequisites

**You must have the Hermes Agent addon already installed and running.**

The Agent addon must expose its gateway and dashboard APIs:

1. In your Hermes Agent addon configuration (`.env`), ensure:
   ```env
   API_SERVER_ENABLED=true
   API_SERVER_HOST=0.0.0.0
   API_SERVER_PORT=8642
   API_SERVER_KEY=your-secret-key-here
   ```

2. The Agent must run the dashboard (add to agent's run.sh or enable `HERMES_DASHBOARD=1`):
   ```bash
   hermes dashboard run &
   hermes gateway run
   ```

3. Verify from HAOS host:
   ```bash
   curl http://<agent-ip>:8642/health
   curl http://<agent-ip>:9119/api/status
   ```

## Installation

1. Add this repository to Home Assistant:
   - Supervisor → Add-on Store → ⋮ → Repositories
   - Add: `https://github.com/krzakx/hermes-workspace-addon`

2. Find "Hermes Workspace" in the addon store and click **Install**

3. Configure the addon options:
   - **Hermes Agent URL**: `http://<agent-ip>:8642` (e.g., `http://172.30.32.1:8642`)
   - **Hermes Dashboard URL**: `http://<agent-ip>:9119`
   - **API Token**: Copy the `API_SERVER_KEY` from your Agent addon
   - **Password**: Set a strong password (required for remote access via Cloudflare)
   - **Cookie Secure**: `true` (if using Cloudflare Tunnel/HTTPS)
   - **Trust Proxy**: `true` (if behind Cloudflare/proxy)

4. Start the addon

5. Open via **Sidebar** (Ingress) or configure Cloudflare Tunnel for external access

## Finding Agent IP

On HAOS host (SSH):
```bash
docker inspect 0a6523c6-hermes-agent | grep IPAddress
# Typical: 172.30.32.x (hassio network)
```

## Volume Sharing

The addon mounts `/config` (maps to `/addon_configs/hermes-workspace/` on host) for:
- `HERMES_HOME` — reads agent memory/skills/sessions (read-only in practice)
- `HERMES_WORKSPACE_DIR` — file browser workspace

The Hermes Agent addon data is at `/addon_configs/0a6523c6_hermes_agent/` on host.

## Upstream

This addon packages upstream releases from:
- **Repository**: https://github.com/outsourc-e/hermes-workspace
- **Docker Images**: ghcr.io/outsourc-e/hermes-workspace:latest-{amd64,arm64}

## License

MIT — based on upstream Hermes Workspace (MIT)