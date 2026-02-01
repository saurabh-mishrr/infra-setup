# Docker Setup with Nginx Reverse Proxy and n8n

A complete Docker-based setup with automated SSL certificate generation, host file management, and nginx reverse proxy configuration.

## 🚀 Features

- **Automated Setup**: Single command to set up everything
- **SSL Certificates**: Automatic generation using mkcert
- **Host File Management**: Automatic /etc/hosts updates
- **Nginx Reverse Proxy**: Production-ready configuration
- **n8n Workflow Automation**: Pre-configured and ready to use
- **Health Checks**: Built-in health monitoring for all services
- **Easy Management**: Simple scripts for start/stop operations

## 📋 Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (version 1.29 or higher) - either standalone `docker-compose` or plugin `docker compose`
- Linux/macOS operating system
- Sudo privileges (for host file modifications)

**Note**: The scripts automatically detect whether you're using `docker-compose` (standalone) or `docker compose` (plugin).

## 🛠️ Installation

### Quick Start

Run the complete setup with a single command:

```bash
chmod +x setup.sh
./setup.sh
```

This script will:
1. Check prerequisites (Docker, Docker Compose)
2. Update /etc/hosts with domain entries
3. Install mkcert (if not already installed)
4. Generate SSL certificates
5. Build Docker images
6. Start all containers

### Manual Setup

If you prefer to run steps individually:

```bash
# 1. Update hosts file
chmod +x update-hosts.sh
./update-hosts.sh

# 2. Generate certificates
chmod +x generate-certs.sh
./generate-certs.sh

# 3. Build and start containers
docker compose build
docker compose up -d
# Or if using standalone: docker-compose build && docker-compose up -d
```

## 📁 Project Structure

```
.
├── setup.sh                    # Main setup script
├── start.sh                    # Quick start script
├── stop.sh                     # Stop all containers
├── generate-certs.sh           # Certificate generation script
├── update-hosts.sh             # Host file management script
├── domains.txt                 # Domain configuration
├── docker-compose.yml          # Docker Compose configuration
├── certs/                      # SSL certificates (generated)
│   ├── cert.pem
│   └── key.pem
└── docker-apps/
    ├── webserver/              # Nginx reverse proxy
    │   ├── Dockerfile
    │   ├── nginx.conf
    │   └── conf.d/
    │       ├── default.conf
    │       └── n8n.conf
    └── n8n/                    # n8n workflow automation
        └── Dockerfile
```

## 🌐 Applications

After setup, you can access:

- **n8n**: https://local.n8n.insta.com

## 🔧 Configuration

### Adding New Domains

1. Edit `domains.txt` and add your domain:
   ```
   local.n8n.insta.com
   local.newapp.insta.com
   ```

2. Re-run the setup scripts:
   ```bash
   ./update-hosts.sh
   ./generate-certs.sh
   ```

3. Add nginx configuration in `docker-apps/webserver/conf.d/newapp.conf`

4. Restart containers:
   ```bash
   docker-compose restart webserver
   ```

### Adding New Applications

1. Create a new directory in `docker-apps/`:
   ```bash
   mkdir -p docker-apps/newapp
   ```

2. Create a Dockerfile for your application

3. Add service to `docker-compose.yml`

4. Create nginx configuration in `docker-apps/webserver/conf.d/`

5. Rebuild and restart:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

## 📝 Useful Commands

### Container Management

```bash
# Start containers
./start.sh
# or
docker compose up -d

# Stop containers
./stop.sh
# or
docker compose down

# Restart containers
docker compose restart

# View logs
docker compose logs -f

# View logs for specific service
docker compose logs -f n8n
docker compose logs -f webserver

# Check container status
docker compose ps

# Rebuild containers
docker compose build --no-cache
docker compose up -d
```

**Note**: If using standalone Docker Compose, replace `docker compose` with `docker-compose`.

### Certificate Management

```bash
# Regenerate certificates
./generate-certs.sh

# View certificate details
openssl x509 -in certs/cert.pem -text -noout
```

### Host File Management

```bash
# Update hosts file
./update-hosts.sh

# View hosts file
cat /etc/hosts

# Restore from backup (if needed)
sudo cp /etc/hosts.backup.YYYYMMDD_HHMMSS /etc/hosts
```

## 🔒 SSL Certificates

This setup uses [mkcert](https://github.com/FiloSottile/mkcert) to generate locally-trusted development certificates. The certificates are:

- **Automatically trusted** by your browser (after mkcert installation)
- **Valid for all domains** listed in `domains.txt`
- **Stored in** `./certs/` directory

### Browser Trust

The first time you access the applications, your browser may show a security warning. This is normal for self-signed certificates. To proceed:

1. Click "Advanced"
2. Click "Proceed to [domain]"

After mkcert installation, certificates will be automatically trusted.

## 🐛 Troubleshooting

### Containers won't start

```bash
# Check logs
docker-compose logs

# Check if ports are already in use
sudo lsof -i :80
sudo lsof -i :443

# Remove all containers and volumes
docker-compose down -v
./setup.sh
```

### Certificate errors

```bash
# Regenerate certificates
rm -rf certs/*
./generate-certs.sh

# Reinstall mkcert CA
mkcert -install
```

### Domain not resolving

```bash
# Verify hosts file
cat /etc/hosts | grep "Docker Setup Domains"

# Re-run hosts update
./update-hosts.sh

# Test DNS resolution
ping local.n8n.insta.com
```

### Permission errors

```bash
# Ensure scripts are executable
chmod +x *.sh

# Check Docker permissions
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

## 🔄 Updates and Maintenance

### Update n8n

```bash
docker-compose pull n8n
docker-compose up -d n8n
```

### Update nginx

```bash
docker-compose build webserver
docker-compose up -d webserver
```

### Backup n8n data

```bash
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup.tar.gz -C /data .
```

### Restore n8n data

```bash
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar xzf /backup/n8n-backup.tar.gz -C /data
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [n8n Documentation](https://docs.n8n.io/)
- [mkcert Documentation](https://github.com/FiloSottile/mkcert)

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⚠️ Important Notes

- This setup is designed for **local development** only
- Do not use self-signed certificates in production
- Keep your Docker images updated for security
- Regularly backup your data volumes
- The setup requires sudo privileges for host file modifications

## 🎯 Next Steps

After successful setup:

1. Access n8n at https://local.n8n.insta.com
2. Create your first workflow
3. Add more applications as needed
4. Customize nginx configurations
5. Set up automated backups

Enjoy your Docker setup! 🚀
