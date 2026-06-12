# HAOS Add-on Dockerfile for Hermes Workspace
# Uses upstream pre-built image as base (already has Node.js, Next.js, all deps)
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Copy entrypoint script
COPY rootfs/run.sh /run.sh
RUN chmod +x /run.sh

# The upstream image already has the app at /usr/src/app
# and runs as non-root user. Just use our entrypoint.
ENTRYPOINT ["/run.sh"]