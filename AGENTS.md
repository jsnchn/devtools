# Agent Instructions for DevContainer Repository

## Build/Test Commands
- **Build container**: `devpod up -t devcontainer .`
- **Delete container**: `devpod delete devcontainer`
- **Run setup**: `bash .devcontainer/setup-devcontainer.sh`, but only ever do this inside the container
- **No test framework detected** - Ask user for test commands if needed
- **Git Version Control** - Never commit or push without permission

## Code Style Guidelines
- **Shell Scripts**: Use bash with `set -euo pipefail`, proper error handling
- **Formatting**: 2 spaces for indentation (see stylua.toml for Lua)
- **File Organization**: Keep dotfiles in `.devcontainer/dotfiles/`
- **Error Handling**: Always check command success with `|| { echo "error"; exit 1; }`
- **Logging**: Use tee for logging setup scripts to `/tmp/` directory

## Project Structure
- `.devcontainer/`: Container configuration and setup scripts
- `.devcontainer/dotfiles/`: User configuration files (zsh, tmux, nvim, etc.)
- This is a development environment setup, not an application codebase

## Important Notes
- Primary user is `jsnchn` (UID 1000)
- Uses mise for version management, tmux for terminal multiplexing
- Neovim with LazyVim is the primary editor