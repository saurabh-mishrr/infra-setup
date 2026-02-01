#!/bin/bash

# Stop Script
# This script stops all Docker containers

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
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

echo -e "${CYAN}Stopping Docker containers...${NC}"

$DOCKER_COMPOSE down

echo -e "${GREEN}Containers stopped successfully!${NC}"
