#!/bin/bash
set -e

REPO="NUU-Cognition/flint"
INSTALL_DIR="$HOME/.nuucognition/flint"
FORCE=false

# Parse args
for arg in "$@"; do
  case $arg in
    --force|-f) FORCE=true ;;
  esac
done

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

# Get latest release info (returns "version|tarball_url")
get_latest_release() {
  curl -s "https://api.github.com/repos/$REPO/releases/latest"
}

# Get installed version
get_installed_version() {
  if [ -f "$INSTALL_DIR/package.json" ]; then
    node -e "console.log(require('$INSTALL_DIR/package.json').version)" 2>/dev/null || echo ""
  else
    echo ""
  fi
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
  RELEASE_JSON=$(get_latest_release)

  LATEST_VERSION=$(echo "$RELEASE_JSON" | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
  TARBALL_URL=$(echo "$RELEASE_JSON" | grep "browser_download_url.*tar.gz" | cut -d'"' -f4)

  if [ -z "$TARBALL_URL" ]; then
    error "Could not find latest release. Check https://github.com/$REPO/releases"
  fi

  # Check if already up to date
  INSTALLED_VERSION=$(get_installed_version)
  if [ -n "$INSTALLED_VERSION" ] && [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ] && [ "$FORCE" = false ]; then
    info "Already up to date (v$INSTALLED_VERSION)"
    echo ""
    echo "  Use --force to reinstall."
    echo ""
    exit 0
  fi

  if [ -n "$INSTALLED_VERSION" ]; then
    info "Updating v$INSTALLED_VERSION → v$LATEST_VERSION"
  else
    info "Installing v$LATEST_VERSION"
  fi

  # Clean existing install
  if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
  fi

  mkdir -p "$INSTALL_DIR"
  curl -sL "$TARBALL_URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1

  # FIX: Set execute permission on bin/flint (needed when tarball created on Windows)
  chmod +x "$INSTALL_DIR/bin/flint"

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
