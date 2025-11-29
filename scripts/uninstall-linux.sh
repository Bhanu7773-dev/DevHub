#!/bin/bash

# DevHub Linux Uninstaller Script
# This script removes DevHub from your system

set -e

APP_NAME="devhub"
INSTALL_DIR="/opt/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
BIN_LINK="/usr/local/bin/$APP_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}"
echo "╔════════════════════════════════════════╗"
echo "║       DevHub Linux Uninstaller         ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}This script requires sudo privileges to uninstall.${NC}"
    echo "Please enter your password:"
    exec sudo bash "$0" "$@"
fi

# Confirm uninstall
read -p "Are you sure you want to uninstall DevHub? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo -e "${YELLOW}Uninstalling DevHub...${NC}"

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
fi

# Remove desktop entry
if [ -f "$DESKTOP_FILE" ]; then
    echo "Removing desktop entry..."
    rm -f "$DESKTOP_FILE"
fi

# Remove symlink
if [ -L "$BIN_LINK" ]; then
    echo "Removing command-line shortcut..."
    rm -f "$BIN_LINK"
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications/ 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ DevHub has been uninstalled.${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Thank you for using DevHub!"
