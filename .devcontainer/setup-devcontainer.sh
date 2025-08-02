#!/bin/bash
set -euo pipefail

# Enable logging
exec 1> >(tee -a /tmp/setup-devcontainer.log)
exec 2>&1

echo "Starting development environment setup at $(date)..."
echo "Running as user: $(whoami)"
echo "Home directory: $HOME"

# Fix ownership
chown -R jsnchn:jsnchn /home/jsnchn

# Copy dotfiles to home directory
echo "Copying dotfiles to home directory..."
cp -r /usr/local/share/dotfiles/.zshrc /home/jsnchn/.zshrc
cp -r /usr/local/share/dotfiles/.zprofile /home/jsnchn/.zprofile
cp -r /usr/local/share/dotfiles/.tmux.conf /home/jsnchn/
cp -r /usr/local/share/dotfiles/.config /home/jsnchn/
cp -r /usr/local/share/dotfiles/.default-npm-packages /home/jsnchn/

# Install tmux plugin manager
echo "Installing tmux plugin manager..."
if sudo -u jsnchn git clone https://github.com/tmux-plugins/tpm /home/jsnchn/.tmux/plugins/tpm; then
    echo "TPM installed successfully"
else
    echo "Warning: Failed to install TPM, but continuing..."
fi

# Install fzf (user-specific installation)
echo "Installing fzf..."
sudo -u jsnchn git clone --depth 1 https://github.com/junegunn/fzf.git /home/jsnchn/.fzf
sudo -u jsnchn /home/jsnchn/.fzf/install --all --no-bash --no-fish

# Set up mise tools
echo "Installing mise tools..."
sudo -u jsnchn bash -c 'export PATH="/home/jsnchn/.local/bin:$PATH" && cd /home/jsnchn && /home/jsnchn/.local/bin/mise install -y'

# Install Neovim dependencies after mise installs node/python
echo "Installing Neovim dependencies..."
sudo -u jsnchn bash -c 'export PATH="/home/jsnchn/.local/share/mise/shims:$PATH" && which npm && npm install -g neovim || echo "npm not available yet"'
sudo -u jsnchn bash -c 'export PATH="/home/jsnchn/.local/share/mise/shims:$PATH" && which python3 && pip3 install pynvim || echo "pip3 not available yet"'

# Initialize tmux plugins
echo "Initializing tmux plugins..."
if [ -d "/home/jsnchn/.tmux/plugins/tpm" ]; then
    sudo -u jsnchn bash -c 'tmux start-server && tmux new-session -d && /home/jsnchn/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux kill-server' || echo "Warning: tmux plugin installation failed, but continuing..."
else
    echo "Warning: TPM not found, skipping tmux plugin initialization"
fi

# Verify installations
echo "Verifying tool installations..."
echo -n "git: "; which git && git --version || echo "NOT FOUND"
echo -n "zsh: "; which zsh && zsh --version || echo "NOT FOUND"
echo -n "tmux: "; which tmux && tmux -V || echo "NOT FOUND"
echo -n "nvim: "; which nvim && nvim --version | head -1 || echo "NOT FOUND"
echo -n "lazygit: "; which lazygit && lazygit --version | head -1 || echo "NOT FOUND"
echo -n "slumber: "; which slumber && slumber --version || echo "NOT FOUND"
echo -n "harlequin: "; which harlequin && harlequin --version || echo "NOT FOUND"
echo -n "fzf: "; test -f /home/jsnchn/.fzf/bin/fzf && /home/jsnchn/.fzf/bin/fzf --version || echo "NOT FOUND"
echo -n "mise: "; test -f /home/jsnchn/.local/bin/mise && /home/jsnchn/.local/bin/mise --version || echo "NOT FOUND"
echo -n "rg: "; which rg && rg --version | head -1 || echo "NOT FOUND"
echo -n "fd: "; which fd && fd --version || echo "NOT FOUND"
echo -n "direnv: "; which direnv && direnv version || echo "NOT FOUND"

echo "Development environment setup complete at $(date)!"
echo "Check /tmp/setup-devcontainer.log for detailed output"