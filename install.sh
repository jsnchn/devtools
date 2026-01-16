#!/bin/bash
set -euo pipefail

# Devtools bootstrap script
# Usage: curl -fsSL https://raw.githubusercontent.com/jsnchn/devtools/main/install.sh | bash

DEVTOOLS_REPO_SSH="git@github.com:jsnchn/devtools.git"
DEVTOOLS_REPO_HTTPS="https://github.com/jsnchn/devtools.git"
DEVTOOLS_DIR="${HOME}/.devtools"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      error "Unsupported operating system: $(uname -s)" ;;
  esac
}

install_prerequisites_macos() {
  # Install Xcode Command Line Tools if needed
  if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please complete the Xcode installation and re-run this script."
    exit 0
  fi

  # Install Homebrew if needed
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  # Install git via brew if needed
  if ! command -v git &>/dev/null; then
    info "Installing git..."
    brew install git
  fi
}

install_prerequisites_linux() {
  # Update package lists and install git
  if ! command -v git &>/dev/null; then
    info "Installing git..."
    if command -v apt-get &>/dev/null; then
      sudo apt-get update
      sudo apt-get install -y git curl
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y git curl
    elif command -v pacman &>/dev/null; then
      sudo pacman -Sy --noconfirm git curl
    else
      error "Unsupported package manager. Please install git manually."
    fi
  fi
}

clone_or_update_repo() {
  if [[ -d "$DEVTOOLS_DIR" ]]; then
    info "Updating existing devtools..."
    cd "$DEVTOOLS_DIR"
    git pull --rebase origin main || git pull origin main
  else
    info "Cloning devtools repository..."
    # Try SSH first (for push access), fall back to HTTPS
    if git clone "$DEVTOOLS_REPO_SSH" "$DEVTOOLS_DIR" 2>/dev/null; then
      info "Cloned via SSH"
    else
      info "SSH failed, using HTTPS..."
      git clone "$DEVTOOLS_REPO_HTTPS" "$DEVTOOLS_DIR"
    fi
  fi

  # Always set remote to SSH (for push access)
  cd "$DEVTOOLS_DIR"
  local current_remote
  current_remote=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ "$current_remote" != "$DEVTOOLS_REPO_SSH" ]]; then
    info "Setting remote to SSH..."
    git remote set-url origin "$DEVTOOLS_REPO_SSH"
  fi
}

setup_git_config() {
  # Set git identity if not already configured
  if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
    info "Setting git user.email..."
    git config --global user.email "jchen.json@gmail.com"
  fi
  if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
    info "Setting git user.name..."
    git config --global user.name "Jason Chen"
  fi
}

start_syncthing() {
  local os="$1"
  if [[ "$os" == "macos" ]]; then
    if command -v brew &>/dev/null; then
      brew services start syncthing 2>/dev/null || true
    fi
  else
    if command -v systemctl &>/dev/null; then
      systemctl --user enable syncthing 2>/dev/null || true
      systemctl --user start syncthing 2>/dev/null || true
    fi
  fi
}

main() {
  echo ""
  echo "======================================"
  echo "       Devtools Bootstrap Script      "
  echo "======================================"
  echo ""

  local OS
  OS=$(detect_os)
  info "Detected OS: $OS"

  # Pre-authenticate sudo on Linux to avoid multiple password prompts
  if [[ "$OS" == "linux" ]]; then
    info "Requesting sudo access (you may be prompted for your password)..."
    if sudo -v; then
      # Keep sudo session alive in the background
      (while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done) &
      SUDO_KEEPALIVE_PID=$!
      trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT
    else
      warn "Could not obtain sudo access. Some steps may fail."
    fi
  fi

  # Step 1: Install prerequisites (git, brew on macOS)
  step "Installing prerequisites..."
  if [[ "$OS" == "macos" ]]; then
    install_prerequisites_macos
  else
    install_prerequisites_linux
  fi

  # Step 2: Configure git identity
  step "Configuring git..."
  setup_git_config

  # Step 3: Clone or update repository
  step "Setting up devtools repository..."
  clone_or_update_repo

  # Step 4: Run installation scripts
  step "Installing packages..."
  "$DEVTOOLS_DIR/scripts/install-packages.sh" "$OS"

  step "Installing tools..."
  "$DEVTOOLS_DIR/scripts/install-tools.sh" "$OS"

  step "Linking dotfiles..."
  "$DEVTOOLS_DIR/scripts/link-dotfiles.sh"

  step "Setting up shell..."
  "$DEVTOOLS_DIR/scripts/setup-shell.sh"

  # Step 5: Install mise runtimes
  step "Installing language runtimes via mise..."
  local MISE_CMD=""
  if command -v mise &>/dev/null; then
    MISE_CMD="mise"
  elif [[ -f "$HOME/.local/bin/mise" ]]; then
    MISE_CMD="$HOME/.local/bin/mise"
  fi

  if [[ -n "$MISE_CMD" ]]; then
    $MISE_CMD trust "$HOME/.config/mise/config.toml" 2>/dev/null || true
    $MISE_CMD install -y || warn "mise install failed, you can run 'mise install' manually later"
  fi

  # Step 6: Start Syncthing for config synchronization
  step "Starting Syncthing..."
  start_syncthing "$OS"

  # Step 7: Start devtools watcher for auto-install on sync
  step "Starting devtools watcher..."
  "$DEVTOOLS_DIR/scripts/setup-watcher.sh"

  echo ""
  echo "======================================"
  echo "       Installation Complete!         "
  echo "======================================"
  echo ""
  info "Syncthing UI: http://localhost:8384"
  info "To sync changes: devtools-sync"
  echo ""
}

main "$@"
