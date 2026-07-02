# HAOS Add-on Dockerfile for Hermes Workspace
# Uses upstream multi-arch image as base
ARG BUILD_VERSION=2.3.0
FROM ghcr.io/outsourc-e/hermes-workspace:${BUILD_VERSION}

# Copy entrypoint script
COPY rootfs/run.sh /run.sh
RUN chmod +x /run.sh

# The upstream image already has the app at /usr/src/app
ENTRYPOINT ["/run.sh"]
