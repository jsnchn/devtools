#!/bin/bash
set -euo pipefail

# Enable logging
exec 1> >(tee -a /tmp/setup-devcontainer.log)
exec 2>&1

echo "Starting development environment setup at $(date)..."
echo "Running as user: $(whoami)"
echo "Home directory: $HOME"

# Install required packages
echo "Installing system packages..."
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
    nodejs \
    npm \
    golang \
    rustc \
    cargo \
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
sudo -u jsnchn git clone https://github.com/tmux-plugins/tpm /home/jsnchn/.tmux/plugins/tpm

# Install Neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar xzf nvim-linux64.tar.gz
mv nvim-linux64 /opt/nvim
ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim
rm nvim-linux64.tar.gz

# LazyVim dependencies are already installed above

# Install language servers and tools for Neovim
npm install -g neovim
pip3 install pynvim

# Install lazygit
echo "Installing lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.40.2")
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit /usr/local/bin
rm -f lazygit.tar.gz lazygit

# Install slumber HTTP client
curl -LO https://github.com/LucasPickering/slumber/releases/latest/download/slumber-x86_64-unknown-linux-gnu
chmod +x slumber-x86_64-unknown-linux-gnu
mv slumber-x86_64-unknown-linux-gnu /usr/local/bin/slumber

# Install harlequin SQL client
pip3 install harlequin

# Install fzf
sudo -u jsnchn git clone --depth 1 https://github.com/junegunn/fzf.git /home/jsnchn/.fzf
sudo -u jsnchn /home/jsnchn/.fzf/install --all --no-bash --no-fish

# Install lazydocker
echo "Installing lazydocker..."
LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.23.1")
curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
tar xf lazydocker.tar.gz lazydocker
install lazydocker /usr/local/bin
rm -f lazydocker.tar.gz lazydocker

# Set up mise tools
sudo -u jsnchn bash -c 'export PATH="/home/jsnchn/.local/bin:$PATH" && /home/jsnchn/.local/bin/mise install'

# Initialize tmux plugins
echo "Initializing tmux plugins..."
sudo -u jsnchn bash -c 'tmux start-server && tmux new-session -d && /home/jsnchn/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux kill-server' || echo "Warning: tmux plugin installation failed, but continuing..."

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