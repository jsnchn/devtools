# Local Development Infrastructure

Optional Docker-based infrastructure services for local development.

## Services

| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL | 5432 | SQL database |
| Redis | 6379 | In-memory cache/store |
| Elasticsearch | 9200 | Search engine |
| MinIO | 9000/9001 | S3-compatible object storage |

## Usage

```bash
# Copy to your project (optional)
cp -r ~/.dotfiles/infrastructure ~/myproject/

# Or run directly from dotfiles
cd ~/.dotfiles/infrastructure

# Copy and customize environment
cp .env.example .env

# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d postgres redis

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes (reset data)
docker-compose down -v
```

## Connection Info

### PostgreSQL
- Host: `localhost`
- Port: `5432`
- User: `jsnchn`
- Password: `postgres`
- Database: `app_dev`
- URL: `postgresql://jsnchn:postgres@localhost:5432/app_dev`

### Redis
- Host: `localhost`
- Port: `6379`
- URL: `redis://localhost:6379`

### Elasticsearch
- Host: `localhost`
- Port: `9200`
- URL: `http://localhost:9200`

### MinIO
- API: `http://localhost:9000`
- Console: `http://localhost:9001`
- Access Key: `admin`
- Secret Key: `password`
