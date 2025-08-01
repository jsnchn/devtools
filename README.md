# Portable Development Environment

This repository contains a portable development environment based on Ubuntu 22.04 with all my development tools and configurations.

## Features

- **Shell**: Zsh with custom configuration
- **Terminal Multiplexer**: tmux with plugins
- **Editor**: Neovim with LazyVim
- **Version Manager**: mise for managing development tools
- **Git Tools**: git, lazygit
- **Docker Tools**: lazydocker
- **HTTP Client**: slumber
- **SQL Client**: harlequin
- **Utilities**: curl, wget, ripgrep, fd-find, direnv, fzf

## Usage

### With GitHub Copilot Token

To use the OpenCode GitHub integration, set your GitHub Copilot token as an environment variable before building:

```bash
export GITHUB_COPILOT_TOKEN="your_github_pat_token_here"
```

Then open the project in any tool that supports devcontainers.

### Without Token

The devcontainer will work without the token, but the OpenCode GitHub integration will not be functional.

## Security Note

Never commit your GitHub token to the repository. The token should be provided via environment variable only.
