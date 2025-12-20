#!/bin/bash
set -e

REPO="NUU-Cognition/flint"
INSTALL_DIR="$HOME/.flint-cli"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[info]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; exit 1; }

# Check Node 20+
check_node() {
  if ! command -v node &> /dev/null; then
    error "Node.js not found. Install Node 20+ first: https://nodejs.org"
  fi
  NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_VERSION" -lt 20 ]; then
    error "Node 20+ required (found v$NODE_VERSION). Update Node: https://nodejs.org"
  fi
  info "Node $(node -v) detected"
}

# Get latest release asset URL
get_latest_release() {
  curl -s "https://api.github.com/repos/$REPO/releases/latest" \
    | grep "browser_download_url.*tar.gz" \
    | cut -d'"' -f4
}

# Main
main() {
  echo ""
  echo "  ╭─────────────────────────────╮"
  echo "  │     Installing Flint        │"
  echo "  ╰─────────────────────────────╯"
  echo ""

  check_node

  info "Fetching latest release..."
  TARBALL_URL=$(get_latest_release)

  if [ -z "$TARBALL_URL" ]; then
    error "Could not find latest release. Check https://github.com/$REPO/releases"
  fi

  info "Downloading from $TARBALL_URL"

  # Clean existing install
  if [ -d "$INSTALL_DIR" ]; then
    warn "Updating existing installation at $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
  fi

  mkdir -p "$INSTALL_DIR"
  curl -sL "$TARBALL_URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1

  # Symlink to PATH
  if sudo ln -sf "$INSTALL_DIR/bin/flint" /usr/local/bin/flint 2>/dev/null; then
    info "Linked to /usr/local/bin/flint"
  else
    mkdir -p "$HOME/.local/bin"
    ln -sf "$INSTALL_DIR/bin/flint" "$HOME/.local/bin/flint"
    info "Linked to ~/.local/bin/flint"

    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      warn "Add ~/.local/bin to your PATH:"
      echo ""
      echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
      echo ""
    fi
  fi

  echo ""
  info "Flint installed successfully!"
  echo ""
  echo "  Run 'flint --version' to verify."
  echo ""
}

main
