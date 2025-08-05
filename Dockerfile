FROM ubuntu:24.04

# Install essential packages first (excluding neovim)
RUN apt-get update && apt-get install -y \
    git \
    gpg \
    sudo \
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
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set root's shell to zsh
RUN chsh -s /bin/zsh root

# Create symlink for fd-find
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Install mise using the standalone installer
RUN curl https://mise.run | sh && \
    mv /root/.local/bin/mise /usr/local/bin/mise && \
    chmod +x /usr/local/bin/mise

# Install latest Neovim
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
    && tar -C /opt -xzf nvim-linux64.tar.gz \
    && ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim \
    && rm nvim-linux64.tar.gz

# Install lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.40.2") \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && install lazygit /usr/local/bin \
    && rm -f lazygit.tar.gz lazygit

# Copy dotfiles and setup script
COPY dotfiles /usr/local/share/dotfiles
COPY setup-devcontainer.sh /usr/local/share/setup-devcontainer.sh
RUN chmod +x /usr/local/share/setup-devcontainer.sh