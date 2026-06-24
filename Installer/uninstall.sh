#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Localmac Uninstaller             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This will remove:${NC}"
echo "  • Localmac.app from /Applications"
echo "  • All Localmac config files (~/.localmac)"
echo "  • SSL certificates (~/.localmac/certs)"
echo "  • Saved sites data"
echo "  • Nginx site configs for Localmac-managed sites"
echo "  • Localmac preferences and logs"
echo "  • Homebrew tap (ProCloudifyHQ/localmac)"
echo ""
echo -e "${YELLOW}This will NOT remove:${NC}"
echo "  • Homebrew itself"
echo "  • PHP, Nginx, MySQL or other services"
echo "  • Your site files in ~/Sites"
echo "  • Your databases"
echo ""

read -p "Are you sure you want to uninstall Localmac? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# Quit app if running
echo -e "  ${BLUE}→${NC} Quitting Localmac..."
osascript -e 'quit app "Localmac"' 2>/dev/null || true
sleep 1

# Remove app
if [ -d "/Applications/Localmac.app" ]; then
    echo -e "  ${BLUE}→${NC} Removing Localmac.app..."
    rm -rf "/Applications/Localmac.app"
    echo -e "  ${GREEN}✓${NC} Removed /Applications/Localmac.app"
fi

# Remove launch-at-login registration
echo -e "  ${BLUE}→${NC} Removing login item..."
osascript -e 'tell application "System Events" to delete every login item whose name is "Localmac"' 2>/dev/null || true

# Remove config and certs
if [ -d "$HOME/.localmac" ]; then
    echo -e "  ${BLUE}→${NC} Removing ~/.localmac..."
    rm -rf "$HOME/.localmac"
    echo -e "  ${GREEN}✓${NC} Removed ~/.localmac"
fi

# Remove preferences
PLIST="$HOME/Library/Preferences/com.localmac.app.plist"
if [ -f "$PLIST" ]; then
    echo -e "  ${BLUE}→${NC} Removing preferences..."
    rm -f "$PLIST"
    echo -e "  ${GREEN}✓${NC} Removed preferences"
fi

# Remove Application Support
APP_SUPPORT="$HOME/Library/Application Support/Localmac"
if [ -d "$APP_SUPPORT" ]; then
    echo -e "  ${BLUE}→${NC} Removing Application Support data..."
    rm -rf "$APP_SUPPORT"
    echo -e "  ${GREEN}✓${NC} Removed Application Support"
fi

# Remove logs
LOGS="$HOME/Library/Logs/Localmac"
if [ -d "$LOGS" ]; then
    echo -e "  ${BLUE}→${NC} Removing logs..."
    rm -rf "$LOGS"
    echo -e "  ${GREEN}✓${NC} Removed logs"
fi

# Remove Nginx site configs managed by Localmac
NGINX_SITES="/opt/homebrew/etc/nginx/servers"
if [ -d "$NGINX_SITES" ]; then
    echo -e "  ${BLUE}→${NC} Removing Localmac nginx configs..."
    find "$NGINX_SITES" -name "*.test.conf" -delete 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Removed nginx site configs"
fi

# Remove dnsmasq .test rule
DNSMASQ_CONF="/opt/homebrew/etc/dnsmasq.conf"
if [ -f "$DNSMASQ_CONF" ]; then
    echo -e "  ${BLUE}→${NC} Removing dnsmasq .test rule..."
    sed -i '' '/address=\/.test\/127.0.0.1/d' "$DNSMASQ_CONF" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Removed dnsmasq rule"
fi

# Remove /etc/resolver/test
if [ -f "/etc/resolver/test" ]; then
    echo -e "  ${BLUE}→${NC} Removing DNS resolver..."
    sudo rm -f "/etc/resolver/test"
    echo -e "  ${GREEN}✓${NC} Removed /etc/resolver/test"
fi

# Remove Homebrew tap
if brew tap | grep -q "procloudifyhq/localmac"; then
    echo -e "  ${BLUE}→${NC} Removing Homebrew tap..."
    brew untap ProCloudifyHQ/localmac 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Removed Homebrew tap"
fi

# Reload dnsmasq if running
if brew services list | grep -q "dnsmasq started"; then
    echo -e "  ${BLUE}→${NC} Reloading dnsmasq..."
    brew services restart dnsmasq 2>/dev/null || true
fi

# Reload nginx if running
if brew services list | grep -q "nginx started"; then
    echo -e "  ${BLUE}→${NC} Reloading nginx..."
    brew services reload nginx 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Localmac has been uninstalled. ✓    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "Your site files in ~/Sites and databases are untouched."
echo ""
