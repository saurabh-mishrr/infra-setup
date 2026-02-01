# 🌐 Dedicated IP Configuration

Successfully assigned dedicated static IP addresses to all Docker services for better network control and connectivity.

## Network Details

- **Network Name**: `docker_app_network`
- **Subnet**: `172.20.0.0/16`
- **Gateway**: `172.20.0.1`

## Assigned IP Addresses

| Service | Container Name | IP Address | Port |
|---------|---------------|------------|------|
| **Webserver** | `webserver` | `172.20.0.10` | 80, 443 |
| **n8n** | `n8n` | `172.20.0.20` | 5678 |
| **PostgreSQL** | `postgres` | `172.20.0.30` | 5432 |

## Changes Made

1. **docker-compose.yml**:
   - Defined `ipam` config for `app_network` with subnet `172.20.0.0/16`
   - Assigned static `ipv4_address` to each service
   - Updated `n8n` environment to connect to DB via `172.20.0.30`

2. **Nginx Configuration**:
   - Updated upstream proxy to point to `http://172.20.0.20:5678`

3. **PostgreSQL Access**:
   - The existing `pg_hba.conf` already allowed `172.16.0.0/12`, which includes the new `172.20.0.0/16` subnet, so no changes were needed there.

## Verification

You can verify the IP assignments with:

```bash
docker network inspect docker_app_network
```

Test internal connectivity from n8n to postgres:

```bash
docker compose exec n8n ping 172.20.0.30
```
