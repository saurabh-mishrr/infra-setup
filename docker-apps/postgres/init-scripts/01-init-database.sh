#!/bin/bash
set -e

# This script runs during PostgreSQL initialization
# It creates databases, users, and enables extensions based on environment variables

echo "Starting PostgreSQL initialization..."

# Function to create database
create_database() {
    local db_name=$1
    echo "Creating database: $db_name"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE DATABASE $db_name;
EOSQL
}

# Function to create user
create_user() {
    local username=$1
    local password=$2
    local database=$3
    echo "Creating user: $username"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE USER $username WITH PASSWORD '$password';
        GRANT ALL PRIVILEGES ON DATABASE $database TO $username;
EOSQL
}

# Function to enable extension
enable_extension() {
    local db_name=$1
    local extension=$2
    echo "Enabling extension '$extension' in database '$db_name'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db_name" <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS $extension;
EOSQL
}

# Create main database if specified
if [ -n "$POSTGRES_DB" ]; then
    echo "Main database: $POSTGRES_DB"
fi

# Create additional databases
if [ -n "$ADDITIONAL_DATABASES" ]; then
    IFS=',' read -ra DBS <<< "$ADDITIONAL_DATABASES"
    for db in "${DBS[@]}"; do
        db=$(echo "$db" | xargs) # trim whitespace
        if [ -n "$db" ]; then
            create_database "$db"
        fi
    done
fi

# Create additional users
if [ -n "$ADDITIONAL_USERS" ]; then
    IFS=',' read -ra USERS <<< "$ADDITIONAL_USERS"
    for user_spec in "${USERS[@]}"; do
        user_spec=$(echo "$user_spec" | xargs) # trim whitespace
        if [ -n "$user_spec" ]; then
            IFS=':' read -ra USER_PARTS <<< "$user_spec"
            if [ ${#USER_PARTS[@]} -eq 3 ]; then
                create_user "${USER_PARTS[0]}" "${USER_PARTS[1]}" "${USER_PARTS[2]}"
            else
                echo "Warning: Invalid user specification: $user_spec (expected format: username:password:database)"
            fi
        fi
    done
fi

# Enable pgvector extension if requested
if [ "$ENABLE_PGVECTOR" = "true" ]; then
    echo "Enabling pgvector extension..."
    enable_extension "$POSTGRES_DB" "vector"
    
    # Enable for additional databases too
    if [ -n "$ADDITIONAL_DATABASES" ]; then
        IFS=',' read -ra DBS <<< "$ADDITIONAL_DATABASES"
        for db in "${DBS[@]}"; do
            db=$(echo "$db" | xargs)
            if [ -n "$db" ]; then
                enable_extension "$db" "vector"
            fi
        done
    fi
fi

# Enable commonly used extensions
echo "Enabling standard extensions..."
enable_extension "$POSTGRES_DB" "\"uuid-ossp\""
enable_extension "$POSTGRES_DB" "pg_trgm"
enable_extension "$POSTGRES_DB" "btree_gin"
enable_extension "$POSTGRES_DB" "btree_gist"

echo "PostgreSQL initialization completed successfully!"
