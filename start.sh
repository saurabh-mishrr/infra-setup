#!/bin/bash

# Quick Start Script
# This script starts the Docker containers (assumes setup has been run)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Detect Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}Error: Docker Compose not found${NC}"
    exit 1
fi

echo -e "${CYAN}Starting Docker containers...${NC}"

# Check if certificates exist
if [ ! -f "./certs/cert.pem" ] || [ ! -f "./certs/key.pem" ]; then
    echo -e "${YELLOW}Certificates not found. Running full setup...${NC}"
    ./setup.sh
    exit 0
fi

# Start containers
$DOCKER_COMPOSE up -d

echo -e "${GREEN}Containers started successfully!${NC}"
echo -e "${CYAN}Access your applications:${NC}"
echo -e "  ${GREEN}•${NC} n8n: ${YELLOW}https://local.n8n.insta.com${NC}"