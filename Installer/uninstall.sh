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
echo "  • Localmac.app"
echo "  • All config files (~/.localmac)"
echo "  • SSL certificates"
echo "  • Saved sites data"
echo "  • Nginx site configs for Localmac-managed sites"
echo "  • Preferences, logs, and DNS rules"
echo ""
echo -e "${YELLOW}This will NOT remove:${NC}"
echo "  • Homebrew, PHP, Nginx, MySQL or other services"
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

# ─────────────────────────────────────────────
# Detect install method
# ─────────────────────────────────────────────
HOMEBREW_INSTALLED=false
if command -v brew &>/dev/null; then
    if brew list --cask 2>/dev/null | grep -q "^localmac$"; then
        HOMEBREW_INSTALLED=true
    fi
fi

if [ "$HOMEBREW_INSTALLED" = true ]; then
    echo -e "  ${BLUE}→${NC} Detected Homebrew installation — using brew to uninstall..."
    brew uninstall --cask --zap localmac
    echo -e "  ${GREEN}✓${NC} Removed via Homebrew (--zap cleans all files)"
else
    # Manual install — remove everything by hand
    echo -e "  ${BLUE}→${NC} Detected manual installation..."

    if [ -d "/Applications/Localmac.app" ]; then
        echo -e "  ${BLUE}→${NC} Removing Localmac.app..."
        rm -rf "/Applications/Localmac.app"
        echo -e "  ${GREEN}✓${NC} Removed /Applications/Localmac.app"
    fi

    [ -d "$HOME/.localmac" ] && rm -rf "$HOME/.localmac" && echo -e "  ${GREEN}✓${NC} Removed ~/.localmac"
    [ -f "$HOME/Library/Preferences/com.localmac.app.plist" ] && rm -f "$HOME/Library/Preferences/com.localmac.app.plist" && echo -e "  ${GREEN}✓${NC} Removed preferences"
    [ -d "$HOME/Library/Application Support/Localmac" ] && rm -rf "$HOME/Library/Application Support/Localmac" && echo -e "  ${GREEN}✓${NC} Removed Application Support"
    [ -d "$HOME/Library/Logs/Localmac" ] && rm -rf "$HOME/Library/Logs/Localmac" && echo -e "  ${GREEN}✓${NC} Removed logs"
fi

# ─────────────────────────────────────────────
# Shared cleanup (regardless of install method)
# ─────────────────────────────────────────────

# Remove launch-at-login
osascript -e 'tell application "System Events" to delete every login item whose name is "Localmac"' 2>/dev/null || true

# Remove Nginx site configs
NGINX_SITES="/opt/homebrew/etc/nginx/servers"
if [ -d "$NGINX_SITES" ]; then
    COUNT=$(find "$NGINX_SITES" -name "*.test.conf" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$COUNT" -gt 0 ]; then
        find "$NGINX_SITES" -name "*.test.conf" -delete
        echo -e "  ${GREEN}✓${NC} Removed $COUNT nginx site config(s)"
    fi
fi

# Remove dnsmasq .test rule
DNSMASQ_CONF="/opt/homebrew/etc/dnsmasq.conf"
if [ -f "$DNSMASQ_CONF" ]; then
    sed -i '' '/address=\/.test\/127.0.0.1/d' "$DNSMASQ_CONF" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Removed dnsmasq .test rule"
fi

# Remove /etc/resolver/test
if [ -f "/etc/resolver/test" ]; then
    sudo rm -f "/etc/resolver/test"
    echo -e "  ${GREEN}✓${NC} Removed /etc/resolver/test"
fi

# Remove Homebrew tap
if command -v brew &>/dev/null && brew tap 2>/dev/null | grep -q "procloudifyhq/localmac"; then
    brew untap ProCloudifyHQ/localmac 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Removed Homebrew tap"
fi

# Reload services if running
if command -v brew &>/dev/null; then
    brew services list 2>/dev/null | grep -q "dnsmasq.*started" && brew services restart dnsmasq 2>/dev/null || true
    brew services list 2>/dev/null | grep -q "nginx.*started"   && brew services reload  nginx    2>/dev/null || true
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Localmac has been uninstalled ✓    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "Your site files in ~/Sites and databases are untouched."
echo ""
