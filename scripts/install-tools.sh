#!/bin/bash
set -euo pipefail

# Install tools not available via package managers (or need special setup)

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

install_mise() {
  if command -v mise &>/dev/null; then
    info "mise is already installed"
    return
  fi

  if [[ -f "$HOME/.local/bin/mise" ]]; then
    info "mise is already installed at ~/.local/bin/mise"
    return
  fi

  info "Installing mise..."
  curl -fsSL https://mise.run | sh
}

install_uv() {
  if command -v uv &>/dev/null; then
    info "uv is already installed"
    return
  fi

  info "Installing uv..."
  curl -fsSL https://astral.sh/uv/install.sh | sh
}

install_fzf() {
  # On macOS, fzf is installed via brew
  if [[ "$OS" == "macos" ]]; then
    return
  fi

  if [[ -d "$HOME/.fzf" ]]; then
    info "fzf is already installed"
    return
  fi

  info "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish --no-update-rc
}

install_helix_linux() {
  if command -v hx &>/dev/null; then
    info "Helix is already installed"
    return
  fi

  info "Installing Helix..."
  local VERSION
  VERSION=$(curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" | grep -Po '"tag_name": "\K[^"]*' || echo "24.07")

  local ARCH
  ARCH=$(uname -m)
  if [[ "$ARCH" == "aarch64" ]]; then
    ARCH="aarch64"
  else
    ARCH="x86_64"
  fi

  local TEMP_DIR
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  curl -fsSL "https://github.com/helix-editor/helix/releases/download/${VERSION}/helix-${VERSION}-${ARCH}-linux.tar.xz" -o helix.tar.xz
  tar -xf helix.tar.xz

  sudo mv "helix-${VERSION}-${ARCH}-linux/hx" /usr/local/bin/

  # Install runtime
  mkdir -p "$HOME/.config/helix"
  if [[ -d "helix-${VERSION}-${ARCH}-linux/runtime" ]]; then
    cp -r "helix-${VERSION}-${ARCH}-linux/runtime" "$HOME/.config/helix/"
  fi

  cd -
  rm -rf "$TEMP_DIR"
  info "Helix installed successfully"
}

install_lazygit_linux() {
  if command -v lazygit &>/dev/null; then
    info "lazygit is already installed"
    return
  fi

  info "Installing lazygit..."
  local VERSION
  VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.44.1")

  local ARCH
  ARCH=$(uname -m)
  if [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
  else
    ARCH="x86_64"
  fi

  local TEMP_DIR
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/lazygit_${VERSION}_Linux_${ARCH}.tar.gz" -o lazygit.tar.gz
  tar -xzf lazygit.tar.gz lazygit

  sudo install lazygit /usr/local/bin/

  cd -
  rm -rf "$TEMP_DIR"
  info "lazygit installed successfully"
}

install_gh() {
  command -v gh &>/dev/null && return
  info "Installing GitHub CLI..."

  if command -v apt-get &>/dev/null; then
    # Add GitHub's official apt repository
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y gh
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm github-cli
  fi
}

install_tpm() {
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    info "TPM is already installed"
  fi

  # Install tmux plugins
  if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    info "Installing tmux plugins..."
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "tmux plugin install failed"
  fi
}

main() {
  info "Installing tools for $OS..."

  # mise (version manager)
  install_mise

  # uv (Python package runner, used for MCP servers)
  install_uv

  # fzf (Linux only, macOS uses brew)
  install_fzf

  # Helix (Linux only, macOS uses brew)
  if [[ "$OS" == "linux" ]]; then
    install_helix_linux
  fi

  # lazygit (Linux only, macOS uses brew)
  if [[ "$OS" == "linux" ]]; then
    install_lazygit_linux
  fi

  # GitHub CLI (Linux only, macOS uses brew)
  if [[ "$OS" == "linux" ]]; then
    install_gh
  fi

  # TPM (both platforms)
  install_tpm

  info "Tool installation complete!"
}

main
