#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Localmac Uninstaller             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────
# Ask uninstall mode
# ─────────────────────────────────────────────
echo -e "${BOLD}Choose uninstall mode:${NC}"
echo ""
echo "  [1] Standard — remove Localmac app + config only"
echo "      (keeps ~/Sites files and databases)"
echo ""
echo "  [2] Complete — remove everything including"
echo "      all site files (~/Sites) and all databases"
echo ""
read -p "Enter choice [1/2]: " mode

if [[ "$mode" != "1" && "$mode" != "2" ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

if [ "$mode" = "2" ]; then
    SITES_DIR="${HOME}/Sites"
    echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ⚠️  WARNING — COMPLETE REMOVAL SELECTED             ║${NC}"
    echo -e "${RED}║                                                      ║${NC}"
    echo -e "${RED}║  This will permanently delete:                       ║${NC}"
    echo -e "${RED}║  • All files in ~/Sites                              ║${NC}"
    echo -e "${RED}║  • All MySQL / MariaDB databases                     ║${NC}"
    echo -e "${RED}║  • All PostgreSQL databases                          ║${NC}"
    echo -e "${RED}║                                                      ║${NC}"
    echo -e "${RED}║  THIS CANNOT BE UNDONE.                              ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Type DELETE to confirm complete removal: " confirm_word
    if [ "$confirm_word" != "DELETE" ]; then
        echo "Cancelled."
        exit 0
    fi
else
    read -p "Are you sure you want to uninstall Localmac? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

echo ""

# Quit app
echo -e "  ${BLUE}→${NC} Quitting Localmac..."
osascript -e 'quit app "Localmac"' 2>/dev/null || true
sleep 1

# ─────────────────────────────────────────────
# Detect install method and remove app
# ─────────────────────────────────────────────
HOMEBREW_INSTALLED=false
if command -v brew &>/dev/null; then
    if brew list --cask 2>/dev/null | grep -q "^localmac$"; then
        HOMEBREW_INSTALLED=true
    fi
fi

if [ "$HOMEBREW_INSTALLED" = true ]; then
    echo -e "  ${BLUE}→${NC} Detected Homebrew install — running brew uninstall..."
    brew uninstall --cask --zap localmac 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Removed via Homebrew"
else
    echo -e "  ${BLUE}→${NC} Detected manual install..."
    [ -d "/Applications/Localmac.app" ] && rm -rf "/Applications/Localmac.app" && echo -e "  ${GREEN}✓${NC} Removed Localmac.app"
    [ -d "$HOME/.localmac" ]            && rm -rf "$HOME/.localmac"            && echo -e "  ${GREEN}✓${NC} Removed ~/.localmac"
    [ -f "$HOME/Library/Preferences/com.localmac.app.plist" ] && rm -f "$HOME/Library/Preferences/com.localmac.app.plist" && echo -e "  ${GREEN}✓${NC} Removed preferences"
    [ -d "$HOME/Library/Application Support/Localmac" ]       && rm -rf "$HOME/Library/Application Support/Localmac"       && echo -e "  ${GREEN}✓${NC} Removed Application Support"
    [ -d "$HOME/Library/Logs/Localmac" ]                      && rm -rf "$HOME/Library/Logs/Localmac"                      && echo -e "  ${GREEN}✓${NC} Removed logs"
fi

# ─────────────────────────────────────────────
# Shared cleanup
# ─────────────────────────────────────────────

osascript -e 'tell application "System Events" to delete every login item whose name is "Localmac"' 2>/dev/null || true

NGINX_SITES="/opt/homebrew/etc/nginx/servers"
if [ -d "$NGINX_SITES" ]; then
    COUNT=$(find "$NGINX_SITES" -name "*.test.conf" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$COUNT" -gt 0 ]; then
        find "$NGINX_SITES" -name "*.test.conf" -delete
        echo -e "  ${GREEN}✓${NC} Removed $COUNT nginx site config(s)"
    fi
fi

DNSMASQ_CONF="/opt/homebrew/etc/dnsmasq.conf"
[ -f "$DNSMASQ_CONF" ] && sed -i '' '/address=\/.test\/127.0.0.1/d' "$DNSMASQ_CONF" 2>/dev/null || true && echo -e "  ${GREEN}✓${NC} Removed dnsmasq .test rule"

if [ -f "/etc/resolver/test" ]; then
    sudo rm -f "/etc/resolver/test"
    echo -e "  ${GREEN}✓${NC} Removed /etc/resolver/test"
fi

if command -v brew &>/dev/null && brew tap 2>/dev/null | grep -q "procloudifyhq/localmac"; then
    brew untap ProCloudifyHQ/localmac 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Removed Homebrew tap"
fi

# ─────────────────────────────────────────────
# Complete mode — delete sites + databases
# ─────────────────────────────────────────────
if [ "$mode" = "2" ]; then
    echo ""
    echo -e "  ${RED}→${NC} Complete removal — deleting site files and databases..."

    # Delete ~/Sites
    SITES_DIR="${HOME}/Sites"
    if [ -d "$SITES_DIR" ]; then
        echo -e "  ${BLUE}→${NC} Deleting $SITES_DIR..."
        rm -rf "$SITES_DIR"
        echo -e "  ${GREEN}✓${NC} Deleted ~/Sites"
    fi

    # Drop all MySQL/MariaDB databases (except system ones)
    MYSQL="/opt/homebrew/bin/mysql"
    if [ -f "$MYSQL" ] && brew services list 2>/dev/null | grep -qE "(mysql|mariadb).*started"; then
        echo -e "  ${BLUE}→${NC} Dropping all MySQL/MariaDB databases..."
        DBS=$("$MYSQL" -u root -e "SHOW DATABASES;" --batch --skip-column-names 2>/dev/null \
            | grep -vE "^(information_schema|performance_schema|mysql|sys)$" || true)
        if [ -n "$DBS" ]; then
            while IFS= read -r db; do
                "$MYSQL" -u root -e "DROP DATABASE IF EXISTS \`$db\`;" 2>/dev/null || true
                echo -e "  ${GREEN}✓${NC} Dropped database: $db"
            done <<< "$DBS"
        else
            echo -e "  ${GREEN}✓${NC} No user databases found"
        fi
    fi

    # Drop all PostgreSQL databases (except system ones)
    PSQL="/opt/homebrew/bin/psql"
    if [ -f "$PSQL" ] && brew services list 2>/dev/null | grep -q "postgresql.*started"; then
        echo -e "  ${BLUE}→${NC} Dropping all PostgreSQL databases..."
        DBS=$("$PSQL" -U "$(whoami)" -d postgres -t -c \
            "SELECT datname FROM pg_database WHERE datistemplate = false AND datname NOT IN ('postgres');" 2>/dev/null \
            | tr -d ' ' | grep -v '^$' || true)
        if [ -n "$DBS" ]; then
            while IFS= read -r db; do
                "$PSQL" -U "$(whoami)" -d postgres -c "DROP DATABASE IF EXISTS \"$db\";" 2>/dev/null || true
                echo -e "  ${GREEN}✓${NC} Dropped PostgreSQL database: $db"
            done <<< "$DBS"
        else
            echo -e "  ${GREEN}✓${NC} No PostgreSQL user databases found"
        fi
    fi
fi

# Reload services
if command -v brew &>/dev/null; then
    brew services list 2>/dev/null | grep -q "dnsmasq.*started" && brew services restart dnsmasq 2>/dev/null || true
    brew services list 2>/dev/null | grep -q "nginx.*started"   && brew services reload  nginx    2>/dev/null || true
fi

echo ""
if [ "$mode" = "2" ]; then
    echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  Localmac completely removed (sites + DBs) ✓    ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
else
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Localmac has been uninstalled ✓    ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo "Your site files in ~/Sites and databases are untouched."
fi
echo ""
