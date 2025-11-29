#!/bin/bash

# DevHub Standalone Installer
# Users run this after extracting the package

set -e

APP_NAME="devhub"
APP_DISPLAY_NAME="DevHub"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════╗"
echo "║         DevHub for Linux               ║"
echo "║     Essential Developer Tools          ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

echo "Choose installation option:"
echo ""
echo "  1) Run without installing (portable mode)"
echo "  2) Install system-wide (requires sudo)"
echo "  3) Install for current user only (~/.local)"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo -e "${GREEN}Starting DevHub...${NC}"
        "$SCRIPT_DIR/devhub"
        ;;
    2)
        INSTALL_DIR="/opt/$APP_NAME"
        DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
        BIN_LINK="/usr/local/bin/$APP_NAME"
        
        if [ "$EUID" -ne 0 ]; then
            exec sudo bash "$0" "$@"
        fi
        
        echo -e "${YELLOW}Installing system-wide...${NC}"
        
        rm -rf "$INSTALL_DIR" 2>/dev/null || true
        cp -r "$SCRIPT_DIR" "$INSTALL_DIR"
        chmod -R 755 "$INSTALL_DIR"
        
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$APP_DISPLAY_NAME
Comment=Essential Developer Tools
Exec=$INSTALL_DIR/$APP_NAME
Icon=$INSTALL_DIR/data/flutter_assets/assets/icon/app_icon.png
Terminal=false
Type=Application
Categories=Development;Utility;
EOF
        
        ln -sf "$INSTALL_DIR/$APP_NAME" "$BIN_LINK"
        
        echo -e "${GREEN}✓ Installed! Run 'devhub' or find it in your app menu.${NC}"
        ;;
    3)
        INSTALL_DIR="$HOME/.local/share/$APP_NAME"
        DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
        BIN_DIR="$HOME/.local/bin"
        
        echo -e "${YELLOW}Installing for current user...${NC}"
        
        mkdir -p "$BIN_DIR"
        mkdir -p "$(dirname "$DESKTOP_FILE")"
        
        rm -rf "$INSTALL_DIR" 2>/dev/null || true
        cp -r "$SCRIPT_DIR" "$INSTALL_DIR"
        chmod -R 755 "$INSTALL_DIR"
        
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$APP_DISPLAY_NAME
Comment=Essential Developer Tools
Exec=$INSTALL_DIR/$APP_NAME
Icon=$INSTALL_DIR/data/flutter_assets/assets/icon/app_icon.png
Terminal=false
Type=Application
Categories=Development;Utility;
EOF
        
        ln -sf "$INSTALL_DIR/$APP_NAME" "$BIN_DIR/$APP_NAME"
        
        echo -e "${GREEN}✓ Installed! Run 'devhub' or find it in your app menu.${NC}"
        echo -e "${YELLOW}Note: Make sure ~/.local/bin is in your PATH${NC}"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
