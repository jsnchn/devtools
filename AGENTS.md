# Agent Instructions for Devtools Repository

## Commands
- **Install/Update**: `./install.sh`
- **Test on macOS**: Run `./install.sh` locally
- **Test on Linux**: `docker run -it ubuntu:24.04 bash` then curl the install script
- **No test framework** - Ask user for test commands if needed
- **Git Version Control** - Never commit or push without permission. Commit author should always be the user only (no co-authored-by lines)

## Code Style Guidelines
- **Shell Scripts**: Use bash with `set -euo pipefail`, proper error handling
- **Formatting**: Tabs for indentation
- **File Organization**: Configs in `config/`, scripts in `scripts/`
- **Error Handling**: Always check command success
- **Idempotent**: All scripts must be safe to run multiple times

## Project Structure
- `install.sh`: Main bootstrap script (curl-able)
- `scripts/`: Installation helper scripts
- `config/`: All configuration files (symlinked to home)
- `config/zsh/.zshrc.d/`: Modular zsh configs
- `infrastructure/`: Optional Docker services

## Important Notes
- Primary user is `jsnchn`
- Supports both macOS (Homebrew) and Linux (apt)
- Uses mise for version management
- Helix is the primary editor
- All configs are symlinked, not copied
- `devtools-update` alias for easy updates
