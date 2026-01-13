# Portable Development Environment

A reusable devcontainer base stored in GitHub (with Git LFS). Simple and self-hosted.

## Quick Start

### 1. Clone and Load Image

```bash
git clone https://github.com/yourusername/devcontainer.git
cd devcontainer
git lfs pull
./build-image.sh --mode load
```

### 2. Create a New Project

```bash
# From THIS repo, copy the template to your new project
cp -r projects/template /path/to/new/project/.devcontainer
```

Or add as a git submodule:
```bash
git submodule add https://github.com/yourusername/devcontainer.git .devcontainer/base
```

### 3. Start Developing

```bash
cd /path/to/project
docker compose -f .devcontainer/docker-compose.yml up -d
docker exec -it project-devcontainer-1 zsh
```

## One-Time Setup

### Build and Save the Base Image

```bash
# Build and save as tarball
./build-image.sh v1.0.0 --mode both

# Add to Git LFS and push
git lfs track "*.tar.gz"
git add .gitattributes
git add devcontainer-base-*.tar.gz
git commit -m "Add devcontainer base image v1.0.0"
git push
```

### On a New Server

```bash
git clone https://github.com/yourusername/devcontainer.git
cd devcontainer
git lfs pull
./build-image.sh --mode load
```

## Project Structure

```
your-project/
├── .devcontainer/
│   ├── devcontainer.json      # Container config
│   ├── Dockerfile             # Project-specific deps (optional)
│   └── docker-compose.yml     # Local infra
├── .mise.toml                 # Runtime versions
├── .env                       # Environment variables
└── src/
```

## Included Services

- **PostgreSQL** (5432)
- **Redis** (6379)
- **Elasticsearch** (9200)
- **MinIO** (9000/9001)

## Customization

### Add Project Dependencies

Edit `.devcontainer/Dockerfile`:
```dockerfile
FROM devcontainer-base:latest

RUN apt-get install -y postgresql-client redis-tools
```

### Configure Runtimes

Edit `.mise.toml`:
```toml
[tools]
node = "20"
python = "3.12"
go = "1.21"
```

### Environment Variables

Copy and edit `.env`:
```bash
cp .env.example .env
```

## Commands

```bash
# Build image locally
./build-image.sh v1.0.0

# Build and save
./build-image.sh v1.0.0 --mode both

# Save existing image
./build-image.sh v1.0.0 --mode save

# Load from tarball
./build-image.sh v1.0.0 --mode load
```
