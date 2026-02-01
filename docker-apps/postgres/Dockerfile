FROM postgres:17

# Switch to root to install packages
USER root

# Install build dependencies and pgvector
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    postgresql-server-dev-17 \
    ca-certificates && \
    # Install pgvector from source
    cd /tmp && \
    git clone --branch v0.7.4 https://github.com/pgvector/pgvector.git && \
    cd pgvector && \
    make && \
    make install && \
    # Clean up
    cd / && \
    rm -rf /tmp/pgvector && \
    apt-get remove -y build-essential git postgresql-server-dev-17 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy initialization scripts
COPY init-scripts/ /docker-entrypoint-initdb.d/

# Copy custom configuration (optional - postgres image handles this)
# The official postgres image will use these if present
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Set permissions
RUN chmod +x /docker-entrypoint-initdb.d/*.sh

# Switch back to postgres user
USER postgres

# Expose PostgreSQL port
EXPOSE 5432

# The official postgres image already has the correct entrypoint and CMD
# We don't need to override them
