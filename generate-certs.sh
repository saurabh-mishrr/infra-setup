#!/bin/bash

# Certificate Generation Script using mkcert
# This script generates SSL certificates for multiple domains

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CERT_DIR="./certs"
DOMAINS_FILE="./domains.txt"

echo -e "${GREEN}=== SSL Certificate Generation Script ===${NC}"

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo -e "${RED}Error: mkcert is not installed${NC}"
    echo -e "${YELLOW}Installing mkcert...${NC}"
    
    # Detect OS and install mkcert
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check if running as root or with sudo
        if [ "$EUID" -ne 0 ]; then
            echo -e "${YELLOW}Installing mkcert requires sudo privileges${NC}"
            sudo apt-get update
            sudo apt-get install -y libnss3-tools wget
            
            # Download and install mkcert
            wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
            chmod +x mkcert
            sudo mv mkcert /usr/local/bin/
        else
            apt-get update
            apt-get install -y libnss3-tools wget
            
            wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
            chmod +x mkcert
            mv mkcert /usr/local/bin/
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install mkcert
            brew install nss # for Firefox
        else
            echo -e "${RED}Error: Homebrew not found. Please install Homebrew first.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Error: Unsupported operating system${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}mkcert installed successfully${NC}"
fi

# Install local CA
echo -e "${YELLOW}Installing local Certificate Authority...${NC}"
mkcert -install

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

# Read domains from file or use default
if [ -f "$DOMAINS_FILE" ]; then
    echo -e "${GREEN}Reading domains from $DOMAINS_FILE${NC}"
    DOMAINS=$(cat "$DOMAINS_FILE" | tr '\n' ' ')
else
    echo -e "${YELLOW}No domains.txt file found, using default domains${NC}"
    DOMAINS="local.n8n.insta.com localhost 127.0.0.1 ::1"
fi

# Generate certificates
echo -e "${YELLOW}Generating certificates for domains: $DOMAINS${NC}"
cd "$CERT_DIR"

# Generate certificate for all domains
mkcert $DOMAINS

# Rename the generated files to standard names
CERT_FILE=$(ls -t | grep ".pem" | grep -v "key" | head -1)
KEY_FILE=$(ls -t | grep "key.pem" | head -1)

if [ -n "$CERT_FILE" ] && [ -n "$KEY_FILE" ]; then
    mv "$CERT_FILE" "cert.pem"
    mv "$KEY_FILE" "key.pem"
    echo -e "${GREEN}Certificates generated successfully!${NC}"
    echo -e "${GREEN}Certificate: $CERT_DIR/cert.pem${NC}"
    echo -e "${GREEN}Private Key: $CERT_DIR/key.pem${NC}"
else
    echo -e "${RED}Error: Failed to generate certificates${NC}"
    exit 1
fi

cd ..

echo -e "${GREEN}=== Certificate generation completed ===${NC}"
