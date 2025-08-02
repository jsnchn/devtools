#!/bin/bash
set -euo pipefail

# Enable logging
exec 1> >(tee -a /tmp/setup-devcontainer.log)
exec 2>&1

echo "Starting development environment setup at $(date)..."
echo "Running as user: $(whoami)"
echo "Home directory: $HOME"

# Install essential packages only
echo "Installing essential system packages..."
apt-get update || { echo "apt-get update failed"; exit 1; }
apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ripgrep \
    fd-find \
    direnv \
    python3-pip \
    python3-venv \
    tmux \
    zsh \
    jq \
    unzip || { echo "apt-get install failed"; exit 1; }

# Copy dotfiles to home directory
cp -r /usr/local/share/dotfiles/.zshrc /home/jsnchn/.zshrc
cp -r /usr/local/share/dotfiles/.zprofile /home/jsnchn/.zprofile
cp -r /usr/local/share/dotfiles/.tmux.conf /home/jsnchn/
cp -r /usr/local/share/dotfiles/.config /home/jsnchn/
cp -r /usr/local/share/dotfiles/.default-npm-packages /home/jsnchn/

# Opencode config is already copied with other .config files

# Install mise
sudo -u jsnchn bash -c 'curl https://mise.run | sh'
echo 'eval "$(/home/jsnchn/.local/bin/mise activate bash)"' >> /home/jsnchn/.bashrc

# Install tmux plugin manager
echo "Installing tmux plugin manager..."
if sudo -u jsnchn git clone https://github.com/tmux-plugins/tpm /home/jsnchn/.tmux/plugins/tpm; then
    echo "TPM installed successfully"
else
    echo "Warning: Failed to install TPM, but continuing..."
fi

# Install Neovim
echo "Installing Neovim..."
if curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz; then
    if tar xzf nvim-linux64.tar.gz; then
        mv nvim-linux64 /opt/nvim
        ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim
        rm -f nvim-linux64.tar.gz
        echo "Neovim installed successfully"
    else
        echo "Failed to extract Neovim archive"
        rm -f nvim-linux64.tar.gz
    fi
else
    echo "Failed to download Neovim"
fi

# LazyVim dependencies will be installed via mise

# Install lazygit
echo "Installing lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.40.2")
if curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"; then
    if tar xf lazygit.tar.gz lazygit 2>/dev/null; then
        install lazygit /usr/local/bin
        rm -f lazygit.tar.gz lazygit
        echo "lazygit installed successfully"
    else
        echo "Failed to extract lazygit archive"
        rm -f lazygit.tar.gz
    fi
else
    echo "Failed to download lazygit"
fi

# Install slumber HTTP client
echo "Installing slumber..."
curl -LO https://github.com/LucasPickering/slumber/releases/latest/download/slumber-x86_64-unknown-linux-gnu || echo "Warning: Failed to download slumber"
if [ -f slumber-x86_64-unknown-linux-gnu ]; then
    chmod +x slumber-x86_64-unknown-linux-gnu
    mv slumber-x86_64-unknown-linux-gnu /usr/local/bin/slumber
fi

# Install harlequin SQL client
echo "Installing harlequin..."
pip3 install harlequin || echo "Warning: Failed to install harlequin"

# Install fzf
sudo -u jsnchn git clone --depth 1 https://github.com/junegunn/fzf.git /home/jsnchn/.fzf
sudo -u jsnchn /home/jsnchn/.fzf/install --all --no-bash --no-fish

# Install lazydocker
echo "Installing lazydocker..."
LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.23.1")
if curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"; then
    if tar xf lazydocker.tar.gz lazydocker 2>/dev/null; then
        install lazydocker /usr/local/bin
        rm -f lazydocker.tar.gz lazydocker
        echo "lazydocker installed successfully"
    else
        echo "Failed to extract lazydocker archive"
        rm -f lazydocker.tar.gz
    fi
else
    echo "Failed to download lazydocker"
fi

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

# Fix ownership
chown -R jsnchn:jsnchn /home/jsnchn

# Create symlink for fd-find
ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Verify installations
echo "Verifying tool installations..."
echo -n "git: "; which git && git --version || echo "NOT FOUND"
echo -n "zsh: "; which zsh && zsh --version || echo "NOT FOUND"
echo -n "tmux: "; which tmux && tmux -V || echo "NOT FOUND"
echo -n "nvim: "; which nvim && nvim --version | head -1 || echo "NOT FOUND"
echo -n "lazygit: "; which lazygit && lazygit --version | head -1 || echo "NOT FOUND"
echo -n "lazydocker: "; which lazydocker && lazydocker --version || echo "NOT FOUND"
echo -n "slumber: "; which slumber && slumber --version || echo "NOT FOUND"
echo -n "harlequin: "; which harlequin && harlequin --version || echo "NOT FOUND"
echo -n "fzf: "; test -f /home/jsnchn/.fzf/bin/fzf && /home/jsnchn/.fzf/bin/fzf --version || echo "NOT FOUND"
echo -n "mise: "; test -f /home/jsnchn/.local/bin/mise && /home/jsnchn/.local/bin/mise --version || echo "NOT FOUND"
echo -n "rg: "; which rg && rg --version | head -1 || echo "NOT FOUND"
echo -n "fd: "; which fd && fd --version || echo "NOT FOUND"
echo -n "direnv: "; which direnv && direnv version || echo "NOT FOUND"

echo "Development environment setup complete at $(date)!"
echo "Check /tmp/setup-devcontainer.log for detailed output"