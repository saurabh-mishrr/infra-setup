# PostgreSQL 17 with pgvector - Configuration Guide

## Overview

This PostgreSQL setup provides a flexible, production-ready database with pgvector extension support for vector operations. All configurations are managed through environment variables for easy customization.

## Quick Start

### 1. Configure Database Settings

Edit the `.env` file in the root directory:

```bash
# Basic Configuration
POSTGRES_DB=n8n_db
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_PORT=5432

# Enable pgvector extension
ENABLE_PGVECTOR=true
```

### 2. Start PostgreSQL

```bash
docker compose up -d postgres
```

### 3. Verify Installation

```bash
# Check if PostgreSQL is running
docker compose ps postgres

# View logs
docker compose logs -f postgres

# Connect to database
docker compose exec postgres psql -U n8n_user -d n8n_db
```

## Configuration Options

### Basic Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_VERSION` | `17` | PostgreSQL version |
| `POSTGRES_DB` | `n8n_db` | Main database name |
| `POSTGRES_USER` | `n8n_user` | Main database user |
| `POSTGRES_PASSWORD` | `n8n_secure_password_change_me` | User password (CHANGE THIS!) |
| `POSTGRES_PORT` | `5432` | PostgreSQL port |
| `POSTGRES_TIMEZONE` | `UTC` | Database timezone |

### Advanced Settings

#### Create Additional Databases

```bash
# In .env file
ADDITIONAL_DATABASES=app_db,analytics_db,test_db
```

This will create multiple databases automatically during initialization.

#### Create Additional Users

```bash
# In .env file
# Format: username:password:database
ADDITIONAL_USERS=app_user:app_pass:app_db,analytics_user:analytics_pass:analytics_db
```

Each user will be created with full privileges on their specified database.

#### Enable/Disable pgvector

```bash
# In .env file
ENABLE_PGVECTOR=true   # Enable vector extension
# or
ENABLE_PGVECTOR=false  # Disable vector extension
```

## Features

### ✅ Included Extensions

The following PostgreSQL extensions are automatically enabled:

- **pgvector** - Vector similarity search (if `ENABLE_PGVECTOR=true`)
- **uuid-ossp** - UUID generation
- **pg_trgm** - Trigram matching for fuzzy text search
- **btree_gin** - GIN index support for B-tree data types
- **btree_gist** - GiST index support for B-tree data types

### ✅ Optimized Configuration

- Memory settings optimized for development/production
- Connection pooling configured
- Write-Ahead Logging (WAL) enabled for data safety
- Query performance tuning
- Comprehensive logging

## Usage Examples

### Example 1: Single Database Setup (Default)

```bash
# .env
POSTGRES_DB=myapp_db
POSTGRES_USER=myapp_user
POSTGRES_PASSWORD=secure_password_123
ENABLE_PGVECTOR=true
```

### Example 2: Multiple Databases with Different Users

```bash
# .env
POSTGRES_DB=main_db
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin_password

ADDITIONAL_DATABASES=app_db,analytics_db
ADDITIONAL_USERS=app_user:app_pass:app_db,analytics_user:analytics_pass:analytics_db
ENABLE_PGVECTOR=true
```

This creates:
- `main_db` with user `admin`
- `app_db` with user `app_user`
- `analytics_db` with user `analytics_user`
- pgvector enabled on all databases

### Example 3: PostgreSQL Without pgvector

For a future PostgreSQL instance without vector support:

```bash
# .env
POSTGRES_DB=standard_db
POSTGRES_USER=standard_user
POSTGRES_PASSWORD=standard_password
ENABLE_PGVECTOR=false
```

## Connecting to PostgreSQL

### From Host Machine

```bash
# Using psql
psql -h localhost -p 5432 -U n8n_user -d n8n_db

# Using connection string
postgresql://n8n_user:n8n_secure_password_change_me@localhost:5432/n8n_db
```

### From Docker Container

```bash
# Execute psql in the container
docker compose exec postgres psql -U n8n_user -d n8n_db

# Run SQL commands
docker compose exec postgres psql -U n8n_user -d n8n_db -c "SELECT version();"
```

### From Another Docker Container (n8n, etc.)

```bash
# Connection details
Host: postgres
Port: 5432
Database: n8n_db
User: n8n_user
Password: n8n_secure_password_change_me

# Connection string
postgresql://n8n_user:n8n_secure_password_change_me@postgres:5432/n8n_db
```

## Testing pgvector Extension

```sql
-- Connect to database
docker compose exec postgres psql -U n8n_user -d n8n_db

-- Verify pgvector is installed
SELECT * FROM pg_extension WHERE extname = 'vector';

-- Create a table with vector column
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    embedding vector(3)
);

-- Insert sample data
INSERT INTO items (embedding) VALUES 
    ('[1,2,3]'),
    ('[4,5,6]'),
    ('[7,8,9]');

-- Find similar vectors
SELECT * FROM items 
ORDER BY embedding <-> '[3,4,5]' 
LIMIT 3;
```

## Backup and Restore

### Backup Database

```bash
# Backup single database
docker compose exec postgres pg_dump -U n8n_user n8n_db > backup.sql

# Backup all databases
docker compose exec postgres pg_dumpall -U n8n_user > backup_all.sql
```

### Restore Database

```bash
# Restore single database
cat backup.sql | docker compose exec -T postgres psql -U n8n_user -d n8n_db

# Restore all databases
cat backup_all.sql | docker compose exec -T postgres psql -U n8n_user
```

## Performance Tuning

The default configuration in `postgresql.conf` is optimized for development. For production, adjust these settings based on your system:

```conf
# Memory Settings (adjust based on available RAM)
shared_buffers = 256MB          # 25% of RAM
effective_cache_size = 1GB      # 50-75% of RAM
work_mem = 16MB                 # RAM / max_connections / 4

# Connection Settings
max_connections = 100           # Adjust based on your needs
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs postgres

# Check if port is already in use
sudo lsof -i :5432

# Remove and recreate
docker compose down
docker volume rm postgres_data
docker compose up -d postgres
```

### Can't Connect to Database

```bash
# Verify container is running
docker compose ps postgres

# Check if PostgreSQL is accepting connections
docker compose exec postgres pg_isready -U n8n_user

# Verify network connectivity
docker compose exec n8n ping postgres
```

### Reset Database

```bash
# Stop containers
docker compose down

# Remove PostgreSQL data volume
docker volume rm postgres_data

# Start fresh
docker compose up -d postgres
```

## File Structure

```
docker-apps/postgres/
├── Dockerfile                      # PostgreSQL 17 with pgvector
├── postgresql.conf                 # PostgreSQL configuration
├── pg_hba.conf                     # Authentication configuration
└── init-scripts/
    └── 01-init-database.sh         # Database initialization script
```

## Environment Variables Reference

All PostgreSQL configuration is done through environment variables in the `.env` file:

```bash
# Required
POSTGRES_DB=n8n_db
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=n8n_secure_password_change_me

# Optional
POSTGRES_PORT=5432
POSTGRES_TIMEZONE=UTC
ADDITIONAL_DATABASES=db1,db2,db3
ADDITIONAL_USERS=user1:pass1:db1,user2:pass2:db2
ENABLE_PGVECTOR=true
```

## Security Best Practices

1. **Change Default Password**: Always change the default password in `.env`
2. **Use Strong Passwords**: Use complex passwords with special characters
3. **Limit Connections**: Adjust `max_connections` based on actual needs
4. **Regular Backups**: Set up automated backup schedules
5. **Update Regularly**: Keep PostgreSQL updated to the latest version
6. **Network Isolation**: Use Docker networks to isolate database access

## Adding Another PostgreSQL Instance

To add a second PostgreSQL instance (e.g., without pgvector):

1. **Create new directory**:
   ```bash
   mkdir -p docker-apps/postgres-standard
   ```

2. **Copy and modify Dockerfile**:
   ```bash
   cp docker-apps/postgres/Dockerfile docker-apps/postgres-standard/
   # Remove pgvector installation from the new Dockerfile
   ```

3. **Add to docker-compose.yml**:
   ```yaml
   postgres-standard:
     build:
       context: ./docker-apps/postgres-standard
     environment:
       - POSTGRES_DB=standard_db
       - POSTGRES_USER=standard_user
       - POSTGRES_PASSWORD=standard_pass
     ports:
       - "5433:5432"  # Different port
   ```

## Support

For PostgreSQL documentation: https://www.postgresql.org/docs/17/
For pgvector documentation: https://github.com/pgvector/pgvector

---

**Note**: This setup uses Ubuntu 24.04 as the base image for consistency across all containers.
