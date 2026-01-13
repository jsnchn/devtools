FROM ubuntu:24.04

ARG UID=1001
ARG GID=1001
ARG USERNAME=jsnchn
ARG VERSION=1.0.0

LABEL maintainer="Jason Chen <jchen.json@gmail.com>"
LABEL version="${VERSION}"
LABEL description="Base development container with mise, helix, tmux, and common tools"

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
    ca-certificates \
    locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

RUN curl -fsSL https://mise.run | sh \
    && mv /root/.local/bin/mise /usr/local/bin/mise \
    && chmod +x /usr/local/bin/mise

RUN HELIX_VERSION=$(curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" | grep -Po '"tag_name": "\K[^"]*' || echo "24.07") \
    && curl -fsSL "https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-x86_64-linux.tar.xz" | tar -xJ -C /opt \
    && ln -sf /opt/helix-${HELIX_VERSION}-x86_64-linux/hx /usr/local/bin/hx

RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.40.2") \
    && curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" | tar xz lazygit \
    && install lazygit /usr/local/bin \
    && rm -f lazygit.tar.gz lazygit

RUN if ! id -u ${USERNAME} > /dev/null 2>&1; then \
        groupadd --gid ${GID} ${USERNAME} 2>/dev/null || true; \
        useradd --uid ${UID} --gid ${GID} --create-home --shell /bin/zsh ${USERNAME}; \
    fi

RUN echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ${USERNAME}

RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc \
    && echo 'export HELIX_RUNTIME="/opt/helix-"*-x86_64-linux/runtime"' >> ~/.zshrc \
    && echo 'eval "$(mise activate zsh)"' >> ~/.zshrc \
    && mkdir -p ~/.config/mise \
    && touch ~/.config/mise/config.toml

COPY --chown=1001:1001 dotfiles /usr/local/share/dotfiles
COPY --chown=1001:1001 setup-devcontainer.sh /usr/local/share/setup-devcontainer.sh
RUN chmod +x /usr/local/share/setup-devcontainer.sh

WORKDIR /workspaces