#!/bin/bash
set -euo pipefail

# Install system packages

OS="${1:-}"
if [[ -z "$OS" ]]; then
  case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
    *)      echo "Unsupported OS"; exit 1 ;;
  esac
fi

info() { echo "[INFO] $1"; }
warn() { echo "[WARN] $1"; }

install_macos_packages() {
  info "Updating Homebrew..."
  brew update

  local packages=(
    git
    zsh
    tmux
    jq
    ripgrep
    fd
    direnv
    fzf
    mise
    helix
    lazygit
  )

  info "Installing packages: ${packages[*]}"
  brew install "${packages[@]}" || true

  # fzf shell integration
  if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
    "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish --no-update-rc || true
  fi
}

install_linux_packages() {
  info "Updating package lists..."

  if command -v apt-get &>/dev/null; then
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

  elif command -v dnf &>/dev/null; then
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
      gcc
      make
      unzip
    )

    info "Installing packages: ${packages[*]}"
    sudo dnf install -y "${packages[@]}"

  elif command -v pacman &>/dev/null; then
    local packages=(
      git
      zsh
      tmux
      jq
      ripgrep
      fd
      direnv
      curl
      wget
      base-devel
      unzip
    )

    info "Installing packages: ${packages[*]}"
    sudo pacman -Sy --noconfirm "${packages[@]}"
  else
    warn "Unsupported package manager. Please install packages manually."
  fi
}

main() {
  info "Installing packages for $OS..."

  if [[ "$OS" == "macos" ]]; then
    install_macos_packages
  else
    install_linux_packages
  fi

  info "Package installation complete!"
}

main
