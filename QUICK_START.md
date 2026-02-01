#!/bin/bash

# Quick Reference Guide
# Display this file with: cat QUICK_START.md

cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                    DOCKER SETUP - QUICK START GUIDE                       ║
╚═══════════════════════════════════════════════════════════════════════════╝

📦 FIRST TIME SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Run the complete setup:
  
    ./setup.sh

  This will:
    ✓ Check Docker & Docker Compose
    ✓ Update /etc/hosts
    ✓ Install mkcert & generate SSL certificates
    ✓ Build Docker images
    ✓ Start all containers

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 DAILY USAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Start:     ./start.sh
  Stop:      ./stop.sh
  Restart:   docker-compose restart

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 ACCESS YOUR APPLICATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  n8n:  https://local.n8n.insta.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 MONITORING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Status:           docker-compose ps
  All logs:         docker-compose logs -f
  n8n logs:         docker-compose logs -f n8n
  Nginx logs:       docker-compose logs -f webserver

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 COMMON TASKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Rebuild images:           docker-compose build
  Restart specific service: docker-compose restart n8n
  Remove everything:        docker-compose down -v
  Update certificates:      ./generate-certs.sh
  Update hosts file:        ./update-hosts.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🆕 ADD NEW APPLICATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. Add domain to domains.txt
  2. Run: ./update-hosts.sh && ./generate-certs.sh
  3. Create docker-apps/newapp/Dockerfile
  4. Add service to docker-compose.yml
  5. Create docker-apps/webserver/conf.d/newapp.conf
  6. Run: docker-compose build && docker-compose up -d

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🐛 TROUBLESHOOTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Issue: Containers won't start
  Fix:   docker-compose logs
         docker-compose down -v
         ./setup.sh

  Issue: Certificate errors
  Fix:   rm -rf certs/*
         ./generate-certs.sh
         docker-compose restart webserver

  Issue: Domain not resolving
  Fix:   ./update-hosts.sh
         ping local.n8n.insta.com

  Issue: Port already in use
  Fix:   sudo lsof -i :80
         sudo lsof -i :443
         # Stop conflicting service

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 PROJECT STRUCTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  setup.sh              Main setup script
  start.sh              Start containers
  stop.sh               Stop containers
  generate-certs.sh     Generate SSL certificates
  update-hosts.sh       Update /etc/hosts
  domains.txt           Domain configuration
  docker-compose.yml    Container orchestration
  
  docker-apps/
    webserver/          Nginx reverse proxy
    n8n/                n8n workflow automation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 DOCUMENTATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Full documentation:  cat README.md
  Architecture:        cat ARCHITECTURE.txt
  This guide:          cat QUICK_START.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 TIPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • All scripts are in the root directory
  • Certificates are auto-generated in ./certs/
  • Data persists in Docker volumes
  • Logs are in Docker volumes (nginx_logs, n8n_data)
  • Use HTTPS only (HTTP redirects to HTTPS)
  • Browser may warn about self-signed cert (click "Proceed")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 NEXT STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. Run ./setup.sh
  2. Visit https://local.n8n.insta.com
  3. Set up your first n8n workflow
  4. Add more applications as needed

╔═══════════════════════════════════════════════════════════════════════════╗
║                         Happy Coding! 🚀                                  ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
