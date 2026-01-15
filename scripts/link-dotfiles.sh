#!/bin/bash
set -euo pipefail

# Link configs from ~/.devtools/config to home directory

DEVTOOLS_DIR="${DEVTOOLS_DIR:-$HOME/.devtools}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR=""

info() { echo "[INFO] $1"; }
warn() { echo "[WARN] $1"; }

backup_file() {
  local file="$1"

  if [[ -e "$file" ]] || [[ -L "$file" ]]; then
    if [[ -z "$BACKUP_DIR" ]]; then
      BACKUP_DIR="$HOME/.devtools-backup-$(date +%Y%m%d-%H%M%S)"
      mkdir -p "$BACKUP_DIR"
      info "Backing up existing files to: $BACKUP_DIR"
    fi

    local filename
    filename=$(basename "$file")
    mv "$file" "$BACKUP_DIR/$filename"
  fi
}

link_file() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    # Already correctly linked
    return
  fi

  backup_file "$dst"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  info "Linked: $dst -> $src"
}

main() {
  info "Linking configs..."

  # Zsh
  link_file "$DEVTOOLS_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
  link_file "$DEVTOOLS_DIR/config/zsh/.zprofile" "$HOME/.zprofile"

  # Tmux
  link_file "$DEVTOOLS_DIR/config/tmux/.tmux.conf" "$HOME/.tmux.conf"

  # Helix
  mkdir -p "$XDG_CONFIG_HOME/helix"
  link_file "$DEVTOOLS_DIR/config/helix/config.toml" "$XDG_CONFIG_HOME/helix/config.toml"

  # mise
  mkdir -p "$XDG_CONFIG_HOME/mise"
  link_file "$DEVTOOLS_DIR/config/mise/config.toml" "$XDG_CONFIG_HOME/mise/config.toml"

  # OpenCode - merge template with local config
  mkdir -p "$XDG_CONFIG_HOME/opencode"
  "$DEVTOOLS_DIR/scripts/merge-opencode-config.sh" \
    "$DEVTOOLS_DIR/config/opencode/config.json.template" \
    "$DEVTOOLS_DIR/config/opencode/config.local.json" \
    "$XDG_CONFIG_HOME/opencode/config.json"
  info "Generated opencode config: $XDG_CONFIG_HOME/opencode/config.json"

  # Default npm packages (for mise node)
  link_file "$DEVTOOLS_DIR/config/mise/.default-npm-packages" "$HOME/.default-npm-packages"

  info "Configs linked successfully!"

  if [[ -n "$BACKUP_DIR" ]]; then
    warn "Old configs backed up to: $BACKUP_DIR"
  fi
}

main
