#!/bin/bash
set -euo pipefail

# Enable logging
exec 1> >(tee -a /tmp/setup-devcontainer.log)
exec 2>&1

echo "Starting development environment setup at $(date)..."
echo "Running as user: $(whoami)"
echo "Home directory: $HOME"

# Copy dotfiles to home directory
echo "Copying dotfiles to home directory..."
cp -r /usr/local/share/dotfiles/.zshrc /root/.zshrc
cp -r /usr/local/share/dotfiles/.zprofile /root/.zprofile
cp -r /usr/local/share/dotfiles/.tmux.conf /root/
cp -r /usr/local/share/dotfiles/.config /root/
cp -r /usr/local/share/dotfiles/.default-npm-packages /root/

# Configure git
echo "Configuring git..."
git config --global user.email "jchen.json@gmail.com"
git config --global user.name "Jason Chen"

# Install tmux plugin manager
echo "Installing tmux plugin manager..."
if git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm; then
    echo "TPM installed successfully"
else
    echo "Warning: Failed to install TPM, but continuing..."
fi

# Install fzf (user-specific installation)
echo "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
/root/.fzf/install --all --no-bash --no-fish

# Set up mise tools
echo "Installing mise tools..."
cd /root && /usr/local/bin/mise install -y

# Set up Helix runtime (for grammars and themes)
echo "Setting up Helix runtime..."
if [ -d "/opt/helix-"*"-x86_64-linux/runtime" ]; then
    export HELIX_RUNTIME=$(ls -d /opt/helix-*-x86_64-linux/runtime)
    echo "HELIX_RUNTIME set to: $HELIX_RUNTIME"
fi

# Initialize tmux plugins
echo "Initializing tmux plugins..."
if [ -d "/root/.tmux/plugins/tpm" ]; then
    tmux start-server && tmux new-session -d && /root/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux kill-server || echo "Warning: tmux plugin installation failed, but continuing..."
else
    echo "Warning: TPM not found, skipping tmux plugin initialization"
fi

# Verify installations
echo "Verifying tool installations..."
echo -n "git: "; which git && git --version || echo "NOT FOUND"
echo -n "zsh: "; which zsh && zsh --version || echo "NOT FOUND"
echo -n "tmux: "; which tmux && tmux -V || echo "NOT FOUND"
echo -n "hx: "; which hx && hx --version || echo "NOT FOUND"
echo -n "lazygit: "; which lazygit && lazygit --version | head -1 || echo "NOT FOUND"
echo -n "fzf: "; test -f /root/.fzf/bin/fzf && /root/.fzf/bin/fzf --version || echo "NOT FOUND"
echo -n "mise: "; which mise && mise --version || echo "NOT FOUND"
echo -n "rg: "; which rg && rg --version | head -1 || echo "NOT FOUND"
echo -n "fd: "; which fd && fd --version || echo "NOT FOUND"
echo -n "direnv: "; which direnv && direnv version || echo "NOT FOUND"

echo "Development environment setup complete at $(date)!"
echo "Check /tmp/setup-devcontainer.log for detailed output"