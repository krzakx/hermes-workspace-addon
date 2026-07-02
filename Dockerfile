# HAOS Add-on Dockerfile for Hermes Workspace
# Builds from source instead of using pre-built upstream image
# because upstream hasn't published Docker images yet

# ─── build stage ─────────────────────────────────────────────────────────
FROM node:22-slim AS build

ARG BUILD_VERSION=2.3.0

RUN corepack enable && apt-get update && apt-get install -y --no-install-recommends ca-certificates git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone upstream repository at specific version
RUN git clone --depth 1 --branch v${BUILD_VERSION} https://github.com/outsourc-e/hermes-workspace.git /src

WORKDIR /src

# Install deps (cache-friendly: copy only manifests first)
COPY --from=build /src/package.json /src/pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# Copy sources and build
COPY --from=build /src/ .
RUN pnpm build

# ─── runtime stage ────────────────────────────────────────────────────────
FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl tini python3 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r workspace && useradd -r -g workspace -u 10010 -m workspace

WORKDIR /app

# Copy build artefacts + runtime deps
COPY --from=build --chown=workspace:workspace /src/dist ./dist
COPY --from=build --chown=workspace:workspace /src/node_modules ./node_modules
COPY --from=build --chown=workspace:workspace /src/package.json ./package.json
COPY --from=build --chown=workspace:workspace /src/server-entry.js ./server-entry.js
COPY --from=build --chown=workspace:workspace /src/skills ./skills

# Copy HAOS entrypoint
COPY rootfs/run.sh /run.sh
RUN chmod +x /run.sh

ENV NODE_ENV=production \
    PORT=3000 \
    HOST=0.0.0.0 \
    HERMES_API_URL=http://hermes-agent:8642

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1:3000/ >/dev/null || exit 1

ENTRYPOINT ["/run.sh"]
CMD ["node", "--max-old-space-size=2048", "server-entry.js"]
