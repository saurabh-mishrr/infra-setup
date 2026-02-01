#!/bin/bash

# PostgreSQL Management Script
# Handy commands for managing PostgreSQL

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

POSTGRES_USER=${POSTGRES_USER:-n8n_user}
POSTGRES_DB=${POSTGRES_DB:-n8n_db}

show_menu() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}PostgreSQL Management Menu${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${YELLOW}1)${NC} Connect to PostgreSQL (psql)"
    echo -e "  ${YELLOW}2)${NC} Show database list"
    echo -e "  ${YELLOW}3)${NC} Show database size"
    echo -e "  ${YELLOW}4)${NC} Check PostgreSQL version"
    echo -e "  ${YELLOW}5)${NC} Verify pgvector extension"
    echo -e "  ${YELLOW}6)${NC} Show active connections"
    echo -e "  ${YELLOW}7)${NC} Backup database"
    echo -e "  ${YELLOW}8)${NC} Restore database"
    echo -e "  ${YELLOW}9)${NC} View PostgreSQL logs"
    echo -e "  ${YELLOW}10)${NC} Restart PostgreSQL"
    echo -e "  ${YELLOW}11)${NC} Stop PostgreSQL"
    echo -e "  ${YELLOW}12)${NC} Start PostgreSQL"
    echo -e "  ${YELLOW}0)${NC} Exit"
    echo ""
    echo -n "Select option: "
}

connect_psql() {
    echo -e "${GREEN}Connecting to PostgreSQL...${NC}"
    $DOCKER_COMPOSE exec postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
}

show_databases() {
    echo -e "${GREEN}Database List:${NC}"
    $DOCKER_COMPOSE exec postgres psql -U "$POSTGRES_USER" -c "\l"
}

show_db_size() {
    echo -e "${GREEN}Database Sizes:${NC}"
    $DOCKER_COMPOSE exec postgres psql -U "$POSTGRES_USER" -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database ORDER BY pg_database_size(pg_database.datname) DESC;"
}

check_version() {
    echo -e "${GREEN}PostgreSQL Version:${NC}"
    $DOCKER_COMPOSE exec postgres psql -U "$POSTGRES_USER" -c "SELECT version();"
}

verify_pgvector() {
    echo -e "${GREEN}Checking pgvector extension:${NC}"
    $DOCKER_COMPOSE exec postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT * FROM pg_extension WHERE extname = 'vector';"
}

show_connections() {
    echo -e "${GREEN}Active Connections:${NC}"
    $DOCKER_COMPOSE exec postgres psql -U "$POSTGRES_USER" -c "SELECT datname, usename, application_name, client_addr, state FROM pg_stat_activity WHERE datname IS NOT NULL;"
}

backup_database() {
    echo -e "${YELLOW}Enter database name to backup (default: $POSTGRES_DB):${NC}"
    read -r db_name
    db_name=${db_name:-$POSTGRES_DB}
    
    backup_file="backup_${db_name}_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${GREEN}Backing up database '$db_name' to $backup_file...${NC}"
    
    $DOCKER_COMPOSE exec -T postgres pg_dump -U "$POSTGRES_USER" "$db_name" > "$backup_file"
    
    echo -e "${GREEN}Backup completed: $backup_file${NC}"
}

restore_database() {
    echo -e "${YELLOW}Enter backup file path:${NC}"
    read -r backup_file
    
    if [ ! -f "$backup_file" ]; then
        echo -e "${RED}Error: File not found: $backup_file${NC}"
        return
    fi
    
    echo -e "${YELLOW}Enter database name to restore to (default: $POSTGRES_DB):${NC}"
    read -r db_name
    db_name=${db_name:-$POSTGRES_DB}
    
    echo -e "${GREEN}Restoring database '$db_name' from $backup_file...${NC}"
    cat "$backup_file" | $DOCKER_COMPOSE exec -T postgres psql -U "$POSTGRES_USER" -d "$db_name"
    
    echo -e "${GREEN}Restore completed${NC}"
}

view_logs() {
    echo -e "${GREEN}PostgreSQL Logs (Ctrl+C to exit):${NC}"
    $DOCKER_COMPOSE logs -f postgres
}

restart_postgres() {
    echo -e "${YELLOW}Restarting PostgreSQL...${NC}"
    $DOCKER_COMPOSE restart postgres
    echo -e "${GREEN}PostgreSQL restarted${NC}"
}

stop_postgres() {
    echo -e "${YELLOW}Stopping PostgreSQL...${NC}"
    $DOCKER_COMPOSE stop postgres
    echo -e "${GREEN}PostgreSQL stopped${NC}"
}

start_postgres() {
    echo -e "${YELLOW}Starting PostgreSQL...${NC}"
    $DOCKER_COMPOSE start postgres
    echo -e "${GREEN}PostgreSQL started${NC}"
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) connect_psql ;;
        2) show_databases ;;
        3) show_db_size ;;
        4) check_version ;;
        5) verify_pgvector ;;
        6) show_connections ;;
        7) backup_database ;;
        8) restore_database ;;
        9) view_logs ;;
        10) restart_postgres ;;
        11) stop_postgres ;;
        12) start_postgres ;;
        0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
    clear
done
