#!/bin/bash
set -euo pipefail

# Devtools bootstrap script
# Usage: curl -fsSL https://raw.githubusercontent.com/jsnchn/devtools/main/install.sh

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
		Linux)  echo "linux" ;;
		*)      error "Unsupported operating system: $(uname -s). This script only supports Ubuntu." ;;
	esac
}

install_prerequisites() {
	if ! command -v git &>/dev/null; then
		info "Installing git..."
		sudo apt-get update
		sudo apt-get install -y git curl
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

main() {
	echo ""
	echo "======================================"
	echo "       Devtools Bootstrap Script      "
	echo "======================================"
	echo ""

	local OS
	OS=$(detect_os)
	info "Detected OS: $OS"

	# Pre-authenticate sudo to avoid multiple password prompts
	info "Requesting sudo access (you may be prompted for your password)..."
	if sudo -v; then
		# Keep sudo session alive in the background
		(while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done) &
		SUDO_KEEPALIVE_PID=$!
		trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT
	else
		warn "Could not obtain sudo access. Some steps may fail."
	fi

	# Step 1: Install prerequisites
	step "Installing prerequisites..."
	install_prerequisites

	# Step 2: Configure git identity
	step "Configuring git..."
	setup_git_config

	# Step 3: Clone or update repository
	step "Setting up devtools repository..."
	clone_or_update_repo

	# Step 4: Run installation scripts
	step "Installing packages..."
	"$DEVTOOLS_DIR/scripts/install-packages.sh"

	step "Installing tools..."
	"$DEVTOOLS_DIR/scripts/install-tools.sh"

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

	echo ""
	echo "======================================"
	echo "       Installation Complete!         "
	echo "======================================"
	echo ""
	info "To sync changes: devtools-sync"
	echo ""
}

main "$@"
