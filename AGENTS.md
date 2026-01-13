# Agent Instructions for DevContainer Repository

## Build/Test Commands
- **Build base image**: `./build-image.sh <version> [latest]`
- **Push base image**: `PUSH=true ./build-image.sh <version>`
- **Test container locally**: `docker build -t test-devcontainer . && docker run -it test-devcontainer zsh`
- **No test framework detected** - Ask user for test commands if needed
- **Git Version Control** - Never commit or push without permission

## Code Style Guidelines
- **Shell Scripts**: Use bash with `set -euo pipefail`, proper error handling
- **Formatting**: 2 spaces for indentation
- **File Organization**: Keep dotfiles in `dotfiles/`, project templates in `projects/template/`
- **Error Handling**: Always check command success with `|| { echo "error"; exit 1; }`
- **Logging**: Use tee for logging setup scripts to `/tmp/` directory

## Project Structure
- `.devcontainer/`: Base container configuration
- `.devcontainer/Dockerfile`: Base image definition (published to GHCR)
- `projects/template/`: Per-project devcontainer template with local infrastructure
- `dotfiles/`: User configuration files (zsh, tmux, helix, mise, etc.)

## Important Notes
- Primary user is `jsnchn` (UID 1000)
- Uses mise for version management, tmux for terminal multiplexing
- Helix is the primary editor
- Base image is published to `ghcr.io/{user}/devcontainer-base`
- Project template includes docker-compose with PostgreSQL, Redis, Elasticsearch, MinIO