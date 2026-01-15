# Devtools

Cross-platform dev environment setup for macOS and Linux. One command to set up a new machine.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/jsnchn/devtools/main/install.sh | bash
```

This will:
1. Install prerequisites (Homebrew on macOS, git on Linux)
2. Clone the repo to `~/.devtools`
3. Install packages (zsh, tmux, helix, lazygit, fzf, mise, etc.)
4. Symlink configs to home directory
5. Set zsh as default shell
6. Install language runtimes via mise (node, python, go)

## Syncing Changes

```bash
# Push config changes from current machine
devtools-up

# Pull updates on other machines
devtools-down
```

## What's Included

### Tools
- **zsh** - Shell with git-aware prompt
- **tmux** - Terminal multiplexer (Ctrl+Space prefix)
- **helix** - Modal text editor
- **mise** - Runtime version manager (node, python, go)
- **fzf** - Fuzzy finder
- **lazygit** - Terminal UI for git
- **ripgrep** - Fast search
- **fd** - Fast file finder
- **direnv** - Directory-based environment variables

### Configurations
- `config/zsh/` - Shell configuration (modular via .zshrc.d/)
- `config/tmux/` - Tmux with vim-style navigation
- `config/helix/` - Helix editor with onedark theme
- `config/mise/` - Language runtime versions

## Structure

```
~/.devtools/
├── install.sh              # Bootstrap script
├── scripts/
│   ├── install-packages.sh # System packages
│   ├── install-tools.sh    # Additional tools
│   ├── link-dotfiles.sh    # Symlink manager
│   └── setup-shell.sh      # Shell configuration
├── config/
│   ├── zsh/
│   │   ├── .zshrc
│   │   ├── .zprofile
│   │   └── .zshrc.d/       # Modular configs
│   ├── tmux/.tmux.conf
│   ├── helix/config.toml
│   ├── mise/config.toml
│   └── opencode/config.json
└── infrastructure/         # Optional Docker services
    └── docker-compose.yml
```

## Infrastructure (Optional)

Local development services via Docker:

```bash
cd ~/.devtools/infrastructure
cp .env.example .env
docker-compose up -d
```

Services: PostgreSQL (5432), Redis (6379), Elasticsearch (9200), MinIO (9000)

## Customization

### Add a new tool

1. Add to `scripts/install-packages.sh` (brew/apt)
2. Or add to `scripts/install-tools.sh` (manual install)
3. Run `./install.sh` to apply

### Add a new config

1. Add file to `config/` directory
2. Update `scripts/link-dotfiles.sh` to symlink it
3. Run `./install.sh` to apply

### Add platform-specific settings

- macOS: Edit `config/zsh/.zshrc.d/macos.zsh`
- Linux: Edit `config/zsh/.zshrc.d/linux.zsh`
