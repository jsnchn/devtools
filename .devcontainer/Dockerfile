FROM ubuntu:24.04

# Install essential packages
RUN install -dm 755 /etc/apt/keyrings \
    && wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | tee /etc/apt/sources.list.d/mise.list \
	&& apt-get update \
	&& apt-get install -y \
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
    mise \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for fd-find
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

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