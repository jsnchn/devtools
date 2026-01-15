#!/bin/bash
set -euo pipefail

# Set up zsh as the default shell

info() { echo "[INFO] $1"; }
warn() { echo "[WARN] $1"; }

main() {
  local zsh_path
  zsh_path=$(which zsh)

  if [[ -z "$zsh_path" ]]; then
    warn "zsh not found, skipping shell setup"
    return
  fi

  # Check if zsh is already the default shell
  if [[ "$SHELL" == "$zsh_path" ]]; then
    info "zsh is already the default shell"
    return
  fi

  # Ensure zsh is in /etc/shells
  if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
    info "Adding $zsh_path to /etc/shells..."
    echo "$zsh_path" | sudo tee -a /etc/shells
  fi

  # Change default shell
  info "Setting zsh as default shell..."
  if chsh -s "$zsh_path"; then
    info "Default shell changed to zsh"
  else
    warn "Failed to change shell. You may need to run: chsh -s $zsh_path"
  fi
}

main
