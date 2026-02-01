FROM n8nio/n8n:latest

# Set working directory
WORKDIR /home/node

# Create necessary directories
USER root
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

# Switch back to node user
USER node

# Expose n8n port
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:5678/healthz || exit 1

# Use the default entrypoint from the base image
# The n8nio/n8n image already has the correct entrypoint configured
