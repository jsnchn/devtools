# Project DevContainer Template

This template provides a complete development environment with:

## Base Features
- **mise**: Multi-runtime version manager (node, python, go, rust, etc.)
- **helix**: Fast, modal text editor
- **tmux**: Terminal multiplexer
- **zsh**: Shell with oh-my-zsh-like setup
- **lazygit**: TUI for git operations

## Local Infrastructure (via docker-compose)
- **PostgreSQL** (port 5432)
- **Redis** (port 6379)
- **Elasticsearch** (port 9200)
- **MinIO** (ports 9000/9001)

## Usage

1. Copy this template to your project:
   ```bash
   cp -r projects/template /path/to/your/project/.devcontainer
   ```

2. Customize:
   - `.devcontainer/devcontainer.json` - VSCode/remote container settings
   - `.devcontainer/Dockerfile` - Add project-specific dependencies
   - `.mise.toml` - Configure runtime versions (node, python, go, etc.)
   - `.env` - Set environment variables (copy from `.env.example`)

3. Open in VSCode:
   ```bash
   code /path/to/your/project
   ```
   VSCode will prompt to reopen in container.

4. Or use devcontainer CLI:
   ```bash
   devcontainer up --workspace-folder /path/to/your/project
   devcontainer exec --workspace-folder /path/to/your/project zsh
   ```

## Project-Specific Customization

### Adding Dependencies
Edit `.devcontainer/Dockerfile`:
```dockerfile
RUN apt-get install -y \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*
```

### Configuring Tools
Edit `.mise.toml`:
```toml
[tools]
node = "20"
python = "3.11"
go = "1.21"
```

### Overriding Base Settings
Edit `.devcontainer/devcontainer.json`:
```json
{
  "remoteEnv": {
    "CUSTOM_VAR": "value"
  },
  "postCreateCommand": "custom-setup-command"
}
```

## Connecting to Services

Services are available at `localhost` on the specified ports:

```bash
# PostgreSQL
psql -h localhost -U jsnchn -d app_dev

# Redis
redis-cli -p 6379

# MinIO Console
# Open http://localhost:9001 in browser
```
