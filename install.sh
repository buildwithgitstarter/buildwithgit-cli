#!/bin/sh
set -e

# Banner
cat << 'BANNER'

    __          _ __    __         _ __  __           _ __
   / /_  __  __(_) /___/ /       __(_) /_/ /_  ____ _(_) /_
  / __ \/ / / / / / __  / | /| / / / __/ __ \/ __ `/ / __/
 / /_/ / /_/ / / / /_/ /| |/ |/ / / /_/ / / / /_/ / / /_
/_.___/\__,_/_/_/\__,_/ |__/|__/_/\__/_/ /_/\__, /_/\__/
                                           /____/

  Build Your Own X — from scratch.
  https://buildwithgit.com

BANNER

REPO="buildwithgitstarter/buildwithgit-cli"
BINARY="bwg"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Install git if missing
if ! command -v git >/dev/null 2>&1; then
    echo "  Git not found. Installing git..."
    OS_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$OS_NAME" in
        darwin)
            if command -v brew >/dev/null 2>&1; then
                brew install git
            else
                echo "  Installing Xcode Command Line Tools (includes git)..."
                xcode-select --install 2>/dev/null || true
                echo "  Follow the popup to complete installation, then re-run this script."
                exit 1
            fi
            ;;
        linux)
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update -qq && sudo apt-get install -y -qq git
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y git
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y git
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm git
            elif command -v apk >/dev/null 2>&1; then
                sudo apk add git
            else
                echo "  Error: Could not detect package manager. Install git manually."
                exit 1
            fi
            ;;
        *)
            echo "  Error: Install git manually from https://git-scm.com"
            exit 1
            ;;
    esac

    if command -v git >/dev/null 2>&1; then
        echo "  ✔ Git installed: $(git --version)"
    else
        echo "  Error: Git installation failed. Install manually from https://git-scm.com"
        exit 1
    fi
else
    echo "  ✔ Git found: $(git --version)"
fi

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

case "$OS" in
    linux|darwin) ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Fetch latest release tag
API_URL="https://api.github.com/repos/$REPO/releases/latest"
API_RESPONSE=$(curl -s "$API_URL")
TAG=$(echo "$API_RESPONSE" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$TAG" ]; then
    echo "Error: Failed to fetch latest release tag."
    echo ""
    echo "GitHub API response:"
    echo "$API_RESPONSE"
    echo ""
    echo "This usually means:"
    echo "  1. The repo $REPO does not exist on GitHub yet"
    echo "  2. The repo exists but has no releases"
    echo ""
    echo "To fix: create the repo, push code, and run 'make publish'"
    exit 1
fi

echo "Installing $BINARY $TAG for ${OS}_${ARCH}..."

# Download binary
VERSION_NO_V=$(echo "$TAG" | sed 's/^v//')
FILENAME="${BINARY}_${VERSION_NO_V}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/$REPO/releases/download/$TAG/$FILENAME"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading $FILENAME..."
HTTP_CODE=$(curl -sSL -w "%{http_code}" "$URL" -o "$TMPDIR/${BINARY}.tar.gz")

if [ "$HTTP_CODE" != "200" ]; then
    echo ""
    echo "Error: Download failed with HTTP $HTTP_CODE"
    echo "URL: $URL"
    echo ""
    echo "This usually means the release asset does not exist."
    echo "Available assets for $TAG:"
    curl -s "$API_URL" | grep '"name":' | sed -E 's/.*"name": "([^"]+)".*/  - \1/' || true
    exit 1
fi

# Verify archive
FILETYPE=$(file -b "$TMPDIR/${BINARY}.tar.gz" 2>/dev/null || echo "unknown")
case "$FILETYPE" in
    *gzip*) ;;
    *)
        echo ""
        echo "Error: Downloaded file is not a valid archive (got: $FILETYPE)"
        exit 1
        ;;
esac

tar -xzf "$TMPDIR/${BINARY}.tar.gz" -C "$TMPDIR"

# Install
if [ -w "$INSTALL_DIR" ]; then
    mv "$TMPDIR/$BINARY" "$INSTALL_DIR/$BINARY"
else
    echo "Need sudo to install to $INSTALL_DIR"
    sudo mv "$TMPDIR/$BINARY" "$INSTALL_DIR/$BINARY"
fi

echo ""
echo "  ✔ $BINARY installed to $INSTALL_DIR/$BINARY"
"$INSTALL_DIR/$BINARY" --version 2>/dev/null || true
echo ""
echo "  Get started:"
echo "    bwg init <challenge> <your-hash>"
echo "    cd <challenge>"
echo "    # write your code in main.py"
echo "    bwg submit"
echo ""
