#!/bin/bash

# DevHub Linux Installer Script
# This script installs DevHub to your system

set -e

APP_NAME="devhub"
APP_DISPLAY_NAME="DevHub"
INSTALL_DIR="/opt/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
BIN_LINK="/usr/local/bin/$APP_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUNDLE_DIR="$PROJECT_DIR/build/linux/x64/release/bundle"

echo -e "${GREEN}"
echo "╔════════════════════════════════════════╗"
echo "║       DevHub Linux Installer           ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Check if bundle exists
if [ ! -d "$BUNDLE_DIR" ]; then
    echo -e "${RED}Error: Build not found at $BUNDLE_DIR${NC}"
    echo "Please run 'flutter build linux --release' first."
    exit 1
fi

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}This script requires sudo privileges to install system-wide.${NC}"
    echo "Please enter your password:"
    exec sudo bash "$0" "$@"
fi

echo -e "${YELLOW}Installing DevHub...${NC}"

# Remove old installation if exists
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing previous installation..."
    rm -rf "$INSTALL_DIR"
fi

# Copy bundle to /opt
echo "Copying files to $INSTALL_DIR..."
cp -r "$BUNDLE_DIR" "$INSTALL_DIR"

# Set permissions
chmod -R 755 "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/$APP_NAME"

# Create desktop entry
echo "Creating desktop entry..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$APP_DISPLAY_NAME
Comment=Essential Developer Tools - 20+ utilities for developers
Exec=$INSTALL_DIR/$APP_NAME
Icon=$INSTALL_DIR/data/flutter_assets/assets/icon/app_icon.png
Terminal=false
Type=Application
Categories=Development;Utility;
Keywords=developer;tools;encoder;decoder;json;base64;uuid;password;
StartupWMClass=devhub
EOF

chmod 644 "$DESKTOP_FILE"

# Create symlink for terminal access
echo "Creating command-line shortcut..."
if [ -L "$BIN_LINK" ]; then
    rm "$BIN_LINK"
fi
ln -s "$INSTALL_DIR/$APP_NAME" "$BIN_LINK"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications/ 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ DevHub installed successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "You can now:"
echo "  • Find 'DevHub' in your application menu"
echo "  • Run 'devhub' from any terminal"
echo ""
echo -e "${YELLOW}Enjoy using DevHub! 🚀${NC}"
