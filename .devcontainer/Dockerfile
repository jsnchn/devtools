FROM ubuntu:24.04

# Create user first
RUN useradd -m -s /bin/zsh -u 1000 jsnchn && \
    usermod -aG sudo jsnchn && \
    echo "jsnchn ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install essential packages
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
    neovim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for fd-find
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Install mise using the standalone installer
RUN curl https://mise.run | sh && \
    mv /root/.local/bin/mise /usr/local/bin/mise && \
    chmod +x /usr/local/bin/mise

# Install lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.40.2") \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && install lazygit /usr/local/bin \
    && rm -f lazygit.tar.gz lazygit

# Install slumber HTTP client
RUN curl -LO https://github.com/LucasPickering/slumber/releases/latest/download/slumber-x86_64-unknown-linux-gnu \
    && chmod +x slumber-x86_64-unknown-linux-gnu \
    && mv slumber-x86_64-unknown-linux-gnu /usr/local/bin/slumber

# Install harlequin SQL client
RUN pip3 install harlequin

# Copy dotfiles and setup script
COPY dotfiles /usr/local/share/dotfiles
COPY setup-devcontainer.sh /usr/local/share/setup-devcontainer.sh
RUN chmod +x /usr/local/share/setup-devcontainer.sh