#!/bin/bash
set -euo pipefail

# Devtools bootstrap script
# Usage: curl -fsSL https://raw.githubusercontent.com/jsnchn/devtools/main/install.sh | bash

DEVTOOLS_REPO="git@github.com:jsnchn/devtools.git"
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
    git clone "$DEVTOOLS_REPO" "$DEVTOOLS_DIR"
  fi
}

check_github_token() {
  local template_file="$DEVTOOLS_DIR/config/opencode/config.json.template"
  local local_file="$DEVTOOLS_DIR/config/opencode/config.local.json"
  local merged_file="$XDG_CONFIG_HOME/opencode/config.json"

  if [[ ! -f "$template_file" ]]; then
    return 0
  fi

  if [[ ! -f "$local_file" ]]; then
    cp "$template_file" "$local_file"
    warn "GitHub MCP server needs a token."
    echo ""
    echo -e "${YELLOW}To get a GitHub Personal Access Token:${NC}"
    echo "  1. Go to: https://github.com/settings/tokens"
    echo "  2. Click 'Generate new token (classic)'"
    echo "  3. Select scopes: 'repo' and 'workflow'"
    echo ""
    read -p "Enter your GitHub token: " token
    if [[ -n "$token" ]]; then
      jq --arg token "$token" '.mcp.github.env.GITHUB_PERSONAL_ACCESS_TOKEN = $token' "$local_file" > "${local_file}.tmp" && mv "${local_file}.tmp" "$local_file"
      "$DEVTOOLS_DIR/scripts/merge-opencode-config.sh" "$template_file" "$local_file" "$merged_file"
      info "Token saved and config merged."
    fi
    return 0
  fi

  if grep -q "YOUR_GITHUB_TOKEN_HERE" "$local_file" 2>/dev/null; then
    warn "GitHub token is still a placeholder."
    echo ""
    echo -e "${YELLOW}To update your token:${NC}"
    echo "  Edit: $local_file"
    echo ""
    read -p "Enter your GitHub token (or press Enter to skip): " token
    if [[ -n "$token" ]]; then
      jq --arg token "$token" '.mcp.github.env.GITHUB_PERSONAL_ACCESS_TOKEN = $token' "$local_file" > "${local_file}.tmp" && mv "${local_file}.tmp" "$local_file"
      "$DEVTOOLS_DIR/scripts/merge-opencode-config.sh" "$template_file" "$local_file" "$merged_file"
      info "Token updated and config merged."
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

  # Step 2: Clone or update repository
  step "Setting up devtools repository..."
  clone_or_update_repo

  # Step 3: Run installation scripts
  step "Installing packages..."
  "$DEVTOOLS_DIR/scripts/install-packages.sh" "$OS"

  step "Installing tools..."
  "$DEVTOOLS_DIR/scripts/install-tools.sh" "$OS"

  step "Linking dotfiles..."
  "$DEVTOOLS_DIR/scripts/link-dotfiles.sh"

  step "Setting up shell..."
  "$DEVTOOLS_DIR/scripts/setup-shell.sh"

  # Step 4: Check for GitHub MCP token
  step "Checking GitHub MCP configuration..."
  check_github_token

  # Step 5: Install mise runtimes
  step "Installing language runtimes via mise..."
  if command -v mise &>/dev/null; then
    mise install -y || warn "mise install failed, you can run 'mise install' manually later"
  elif [[ -f "$HOME/.local/bin/mise" ]]; then
    "$HOME/.local/bin/mise" install -y || warn "mise install failed"
  fi

  echo ""
  echo "======================================"
  echo "       Installation Complete!         "
  echo "======================================"
  echo ""
  info "To push config changes: devtools-up"
  info "To pull updates: devtools-down"
  echo ""
  info "Sourcing ~/.zshrc to load devtools..."
  zsh -c "source ~/.zshrc"
}

main "$@"
