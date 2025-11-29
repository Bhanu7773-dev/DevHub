#!/bin/bash

# DevHub Uninstaller
# Removes DevHub from your system

set -e

APP_NAME="devhub"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}"
echo "╔════════════════════════════════════════╗"
echo "║       DevHub Uninstaller               ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Check what installations exist
SYSTEM_INSTALL="/opt/$APP_NAME"
USER_INSTALL="$HOME/.local/share/$APP_NAME"
SYSTEM_DESKTOP="/usr/share/applications/$APP_NAME.desktop"
USER_DESKTOP="$HOME/.local/share/applications/$APP_NAME.desktop"
SYSTEM_BIN="/usr/local/bin/$APP_NAME"
USER_BIN="$HOME/.local/bin/$APP_NAME"

found=false

if [ -d "$SYSTEM_INSTALL" ]; then
    echo "Found system-wide installation at $SYSTEM_INSTALL"
    found=true
fi

if [ -d "$USER_INSTALL" ]; then
    echo "Found user installation at $USER_INSTALL"
    found=true
fi

if [ "$found" = false ]; then
    echo -e "${YELLOW}DevHub is not installed on this system.${NC}"
    exit 0
fi

echo ""
read -p "Are you sure you want to uninstall DevHub? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo -e "${YELLOW}Uninstalling DevHub...${NC}"

# Remove system-wide installation (needs sudo)
if [ -d "$SYSTEM_INSTALL" ] || [ -f "$SYSTEM_DESKTOP" ] || [ -L "$SYSTEM_BIN" ]; then
    if [ "$EUID" -ne 0 ]; then
        echo "Removing system installation requires sudo..."
        sudo rm -rf "$SYSTEM_INSTALL" 2>/dev/null || true
        sudo rm -f "$SYSTEM_DESKTOP" 2>/dev/null || true
        sudo rm -f "$SYSTEM_BIN" 2>/dev/null || true
    else
        rm -rf "$SYSTEM_INSTALL" 2>/dev/null || true
        rm -f "$SYSTEM_DESKTOP" 2>/dev/null || true
        rm -f "$SYSTEM_BIN" 2>/dev/null || true
    fi
    echo "✓ Removed system installation"
fi

# Remove user installation
if [ -d "$USER_INSTALL" ]; then
    rm -rf "$USER_INSTALL"
    echo "✓ Removed user installation"
fi

if [ -f "$USER_DESKTOP" ]; then
    rm -f "$USER_DESKTOP"
    echo "✓ Removed user desktop entry"
fi

if [ -L "$USER_BIN" ]; then
    rm -f "$USER_BIN"
    echo "✓ Removed user binary link"
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
    sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ DevHub has been uninstalled.${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Thank you for using DevHub!"
