# Portable Development Environment

This repository contains a portable development environment based on Ubuntu 24.04 with all my development tools and configurations.

## Features

- **Shell**: Zsh with custom configuration
- **Terminal Multiplexer**: tmux with plugins
- **Editor**: Neovim with LazyVim
- **Version Manager**: mise for managing development tools
- **Git Tools**: git, lazygit
- **Utilities**: curl, wget, ripgrep, fd-find, direnv, fzf

## Usage

### As a Standalone Project

Open the project in any tool that supports devcontainers (VS Code, DevPod, etc.) and the development environment will be automatically configured with all tools and settings.

```bash
# Using DevPod
devpod up .

# Or with a specific IDE
devpod up --ide vscode .
```

### As a Git Subtree in Other Projects

This repository is designed to be used as a git subtree in other projects. Add it to your project's `.devcontainer` directory:

```bash
# Add as a subtree
git subtree add --prefix=.devcontainer https://github.com/jsnchn/devcontainer.git main --squash

# Update the subtree later
git subtree pull --prefix=.devcontainer https://github.com/jsnchn/devcontainer.git main --squash
```

Then you can use DevPod from your project root:

```bash
devpod up .
```

## Structure

- `devcontainer.json` - Dev container configuration
- `Dockerfile` - Container image definition
- `setup-devcontainer.sh` - Post-create setup script
- `dotfiles/` - Configuration files for various tools
- `AGENTS.md` - Instructions for AI agents
