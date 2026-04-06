#!/bin/bash
set -euo pipefail

# Install system packages (Ubuntu/apt only)

info() { echo "[INFO] $1"; }
warn() { echo "[WARN] $1"; }

install_packages() {
	info "Updating package lists..."
	sudo apt-get update

	local packages=(
		git
		zsh
		tmux
		jq
		ripgrep
		fd-find
		direnv
		curl
		wget
		build-essential
		unzip
	)

	info "Installing packages: ${packages[*]}"
	sudo apt-get install -y "${packages[@]}"

	# Create fd symlink (fd-find -> fd)
	if [[ -f /usr/bin/fdfind ]] && [[ ! -f /usr/local/bin/fd ]]; then
		sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
	fi
}

main() {
	info "Installing packages..."
	install_packages
	info "Package installation complete!"
}

main
