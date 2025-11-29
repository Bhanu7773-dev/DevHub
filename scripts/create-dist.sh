#!/bin/bash

# DevHub Distribution Packager
# Creates a ready-to-distribute package for users

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build/linux/x64/release/bundle"
DIST_DIR="$PROJECT_DIR/dist"
PACKAGE_NAME="devhub-linux-x64"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════╗"
echo "║     DevHub Distribution Packager       ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Check if build exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}Build not found. Building now...${NC}"
    cd "$PROJECT_DIR"
    flutter build linux --release
fi

# Create dist directory
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/$PACKAGE_NAME"

echo -e "${YELLOW}Creating distribution package...${NC}"

# Copy bundle contents
cp -r "$BUILD_DIR"/* "$DIST_DIR/$PACKAGE_NAME/"

# Copy installer and uninstaller scripts
cp "$SCRIPT_DIR/package/install.sh" "$DIST_DIR/$PACKAGE_NAME/"
cp "$SCRIPT_DIR/package/uninstall.sh" "$DIST_DIR/$PACKAGE_NAME/"
chmod +x "$DIST_DIR/$PACKAGE_NAME/install.sh"
chmod +x "$DIST_DIR/$PACKAGE_NAME/uninstall.sh"

# Create README for users
cat > "$DIST_DIR/$PACKAGE_NAME/README.txt" << 'EOF'
╔════════════════════════════════════════════════════════════╗
║                    DevHub for Linux                        ║
║              Essential Developer Tools                     ║
╚════════════════════════════════════════════════════════════╝

QUICK START
───────────
Run the app directly:
    ./devhub

Or use the installer for menu integration:
    ./install.sh

To uninstall:
    ./uninstall.sh


WHAT'S INCLUDED
───────────────
• 20+ Developer Tools
• Base64, URL, HTML Encoders/Decoders
• UUID, Password, Hash Generators  
• JSON, XML, CSS, SQL Formatters
• Color Converter, Regex Tester
• And much more!


REQUIREMENTS
────────────
• Linux (x64)
• GTK 3.0+


SUPPORT
───────
Issues: https://github.com/yourusername/devhub/issues


Enjoy DevHub! 🚀
EOF

# Create tar.gz package
cd "$DIST_DIR"
tar -czvf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"

# Also create a zip for those who prefer it
zip -r "$PACKAGE_NAME.zip" "$PACKAGE_NAME"

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Distribution packages created!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Files ready in: $DIST_DIR/"
echo ""
echo "  📦 $PACKAGE_NAME.tar.gz"
echo "  📦 $PACKAGE_NAME.zip"
echo ""
echo "Share either file with your users!"
