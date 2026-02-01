#!/bin/bash

# Host File Management Script
# This script automatically adds domain entries to /etc/hosts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.backup.$(date +%Y%m%d_%H%M%S)"
DOMAINS_FILE="$SCRIPT_DIR/domains.txt"
MARKER_START="# === Docker Setup Domains - START ==="
MARKER_END="# === Docker Setup Domains - END ==="

echo -e "${GREEN}=== Host File Update Script ===${NC}"
echo -e "${YELLOW}Script directory: $SCRIPT_DIR${NC}"

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}This script requires sudo privileges to modify /etc/hosts${NC}"
    exec sudo -E bash "$0" "$@"
fi

# Backup current hosts file
echo -e "${YELLOW}Creating backup of hosts file: $BACKUP_FILE${NC}"
cp "$HOSTS_FILE" "$BACKUP_FILE"

# Read domains from file or use default
if [ -f "$DOMAINS_FILE" ]; then
    echo -e "${GREEN}Reading domains from $DOMAINS_FILE${NC}"
    mapfile -t DOMAINS < "$DOMAINS_FILE"
else
    echo -e "${YELLOW}No domains.txt file found, using default domains${NC}"
    DOMAINS=("local.n8n.insta.com")
fi

# Remove old entries if they exist
if grep -q "$MARKER_START" "$HOSTS_FILE"; then
    echo -e "${YELLOW}Removing old domain entries...${NC}"
    sed -i "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE"
fi

# Add new entries
echo -e "${YELLOW}Adding new domain entries...${NC}"
{
    echo ""
    echo "$MARKER_START"
    for domain in "${DOMAINS[@]}"; do
        # Skip empty lines and comments
        if [[ -n "$domain" ]] && [[ ! "$domain" =~ ^# ]]; then
            # Remove any existing entry for this domain (outside our markers)
            sed -i "/^127.0.0.1[[:space:]]*$domain$/d" "$HOSTS_FILE"
            echo "127.0.0.1       $domain"
        fi
    done
    echo "$MARKER_END"
} >> "$HOSTS_FILE"

echo -e "${GREEN}=== Host file updated successfully ===${NC}"
echo -e "${GREEN}Added entries for the following domains:${NC}"
for domain in "${DOMAINS[@]}"; do
    if [[ -n "$domain" ]] && [[ ! "$domain" =~ ^# ]]; then
        echo -e "  - $domain"
    fi
done

echo -e "${YELLOW}Backup saved to: $BACKUP_FILE${NC}"
echo -e "${GREEN}You can now access your applications using the configured domains${NC}"
