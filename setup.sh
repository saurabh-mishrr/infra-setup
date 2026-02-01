#!/bin/bash

# Main Setup Script
# This script orchestrates the complete Docker setup process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to print section headers
print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${MAGENTA}$1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to print info messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Main setup process
main() {
    print_header "Docker Setup - Complete Installation"
    
    print_info "Starting setup process..."
    print_info "Working directory: $SCRIPT_DIR"
    
    # Step 1: Check prerequisites
    print_header "Step 1: Checking Prerequisites"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker is installed"
    
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE="docker-compose"
        print_success "Docker Compose is installed (standalone)"
    elif docker compose version &> /dev/null 2>&1; then
        DOCKER_COMPOSE="docker compose"
        print_success "Docker Compose is installed (plugin)"
    else
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Step 2: Update hosts file
    print_header "Step 2: Updating /etc/hosts"
    
    if [ -f "./update-hosts.sh" ]; then
        chmod +x ./update-hosts.sh
        ./update-hosts.sh
        print_success "Hosts file updated successfully"
    else
        print_error "update-hosts.sh not found"
        exit 1
    fi
    
    # Step 3: Generate SSL certificates
    print_header "Step 3: Generating SSL Certificates"
    
    if [ -f "./generate-certs.sh" ]; then
        chmod +x ./generate-certs.sh
        ./generate-certs.sh
        print_success "SSL certificates generated successfully"
    else
        print_error "generate-certs.sh not found"
        exit 1
    fi
    
    # Step 4: Verify certificate files
    print_header "Step 4: Verifying Certificates"
    
    if [ -f "./certs/cert.pem" ] && [ -f "./certs/key.pem" ]; then
        print_success "Certificate files found"
        print_info "Certificate: ./certs/cert.pem"
        print_info "Private Key: ./certs/key.pem"
    else
        print_error "Certificate files not found"
        exit 1
    fi
    
    # Step 5: Stop existing containers (if any)
    print_header "Step 5: Cleaning Up Existing Containers"
    
    if $DOCKER_COMPOSE ps -q 2>/dev/null | grep -q .; then
        print_warning "Stopping existing containers..."
        $DOCKER_COMPOSE down
        print_success "Existing containers stopped"
    else
        print_info "No existing containers found"
    fi
    
    # Step 6: Build Docker images
    print_header "Step 6: Building Docker Images"
    
    print_info "Building images (this may take a few minutes)..."
    $DOCKER_COMPOSE build --no-cache
    print_success "Docker images built successfully"
    
    # Step 7: Start containers
    print_header "Step 7: Starting Docker Containers"
    
    print_info "Starting containers..."
    $DOCKER_COMPOSE up -d
    print_success "Containers started successfully"
    
    # Step 8: Wait for services to be healthy
    print_header "Step 8: Waiting for Services to be Ready"
    
    print_info "Waiting for services to start (this may take up to 60 seconds)..."
    sleep 10
    
    # Check container status
    print_info "Checking container status..."
    $DOCKER_COMPOSE ps
    
    # Step 9: Display access information
    print_header "Setup Complete!"
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${MAGENTA}Your Docker setup is ready!${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Access your applications:${NC}"
    echo -e "  ${GREEN}•${NC} n8n:        ${YELLOW}https://local.n8n.insta.com${NC}"
    echo ""
    echo -e "${CYAN}Useful commands:${NC}"
    echo -e "  ${GREEN}•${NC} View logs:           ${YELLOW}$DOCKER_COMPOSE logs -f${NC}"
    echo -e "  ${GREEN}•${NC} Stop containers:     ${YELLOW}$DOCKER_COMPOSE down${NC}"
    echo -e "  ${GREEN}•${NC} Restart containers:  ${YELLOW}$DOCKER_COMPOSE restart${NC}"
    echo -e "  ${GREEN}•${NC} View status:         ${YELLOW}$DOCKER_COMPOSE ps${NC}"
    echo ""
    echo -e "${CYAN}Certificate Information:${NC}"
    echo -e "  ${GREEN}•${NC} Certificate: ${YELLOW}./certs/cert.pem${NC}"
    echo -e "  ${GREEN}•${NC} Private Key: ${YELLOW}./certs/key.pem${NC}"
    echo ""
    echo -e "${BLUE}Note: Your browser may show a security warning for the first time.${NC}"
    echo -e "${BLUE}This is normal for self-signed certificates. Click 'Advanced' and${NC}"
    echo -e "${BLUE}'Proceed' to access your applications.${NC}"
    echo ""
}

# Run main function
main "$@"
