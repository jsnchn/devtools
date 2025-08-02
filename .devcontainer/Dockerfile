FROM ubuntu:24.04

# Install essential packages first
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

# Remove existing ubuntu user and create jsnchn user with UID 1000
RUN userdel -r ubuntu 2>/dev/null || true && \
    useradd -m -s /bin/zsh -u 1000 jsnchn && \
    usermod -aG sudo jsnchn && \
    echo "jsnchn ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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
RUN SLUMBER_VERSION=$(curl -s https://api.github.com/repos/LucasPickering/slumber/releases/latest | grep -Po '"tag_name": "v\K[^"]*' || echo "3.3.0") \
    && curl -Lo slumber.tar.xz "https://github.com/LucasPickering/slumber/releases/download/v${SLUMBER_VERSION}/slumber-x86_64-unknown-linux-gnu.tar.xz" \
    && tar -xf slumber.tar.xz \
    && install slumber /usr/local/bin \
    && rm -f slumber.tar.xz slumber

# Copy dotfiles and setup script
COPY dotfiles /usr/local/share/dotfiles
COPY setup-devcontainer.sh /usr/local/share/setup-devcontainer.sh
RUN chmod +x /usr/local/share/setup-devcontainer.sh