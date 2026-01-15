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
    if ! echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null 2>&1; then
      warn "Could not add zsh to /etc/shells (needs sudo). Run manually:"
      warn "  echo '$zsh_path' | sudo tee -a /etc/shells"
    fi
  fi

  # Change default shell
  if [[ "$SHELL" != "$zsh_path" ]]; then
    info "Setting zsh as default shell..."
    if chsh -s "$zsh_path" 2>/dev/null; then
      info "Default shell changed to zsh"
    else
      warn "Could not change default shell. Run manually: chsh -s $zsh_path"
    fi
  fi
}

main
