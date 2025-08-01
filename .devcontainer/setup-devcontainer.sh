#!/bin/bash
set -e

echo "Setting up development environment..."

# Install required packages
apt-get update && apt-get install -y \
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
    unzip

# Copy dotfiles to home directory
cp -r /usr/local/share/dotfiles/.zshrc /home/jsnchn/.zshrc
cp -r /usr/local/share/dotfiles/.zprofile /home/jsnchn/.zprofile
cp -r /usr/local/share/dotfiles/.tmux.conf /home/jsnchn/
cp -r /usr/local/share/dotfiles/.config /home/jsnchn/
cp -r /usr/local/share/dotfiles/.default-npm-packages /home/jsnchn/

# Handle opencode config with token substitution
if [ -f "/usr/local/share/dotfiles/.config/opencode/config.json.template" ]; then
    if [ -n "$GITHUB_COPILOT_TOKEN" ]; then
        # Substitute the token if environment variable is set
        sed "s/\${GITHUB_COPILOT_TOKEN}/$GITHUB_COPILOT_TOKEN/g" \
            /usr/local/share/dotfiles/.config/opencode/config.json.template \
            > /home/jsnchn/.config/opencode/config.json
    else
        # Copy template as-is if no token provided
        cp /usr/local/share/dotfiles/.config/opencode/config.json.template \
           /home/jsnchn/.config/opencode/config.json
        echo "Warning: GITHUB_COPILOT_TOKEN not set. OpenCode GitHub integration will not work."
    fi
fi

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
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

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
curl -Lo lazydocker.tar.gz https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_0.23.1_Linux_x86_64.tar.gz
tar xf lazydocker.tar.gz lazydocker
install lazydocker /usr/local/bin
rm lazydocker.tar.gz lazydocker

# Set up mise tools
sudo -u jsnchn bash -c 'export PATH="/home/jsnchn/.local/bin:$PATH" && /home/jsnchn/.local/bin/mise install'

# Initialize tmux plugins
sudo -u jsnchn bash -c 'tmux start-server && tmux new-session -d && /home/jsnchn/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux kill-server'

# Fix ownership
chown -R jsnchn:jsnchn /home/jsnchn

# Create symlink for fd-find
ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Verify installations
echo "Verifying tool installations..."
echo -n "git: "; which git && git --version
echo -n "zsh: "; which zsh && zsh --version
echo -n "tmux: "; which tmux && tmux -V
echo -n "nvim: "; which nvim && nvim --version | head -1
echo -n "lazygit: "; which lazygit && lazygit --version | head -1
echo -n "lazydocker: "; which lazydocker && lazydocker --version
echo -n "slumber: "; which slumber && slumber --version
echo -n "harlequin: "; which harlequin && harlequin --version
echo -n "fzf: "; /home/jsnchn/.fzf/bin/fzf --version
echo -n "mise: "; /home/jsnchn/.local/bin/mise --version
echo -n "rg: "; which rg && rg --version | head -1
echo -n "fd: "; which fd && fd --version
echo -n "direnv: "; which direnv && direnv version

echo "Development environment setup complete!"