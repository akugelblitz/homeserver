# Homeserver Stack Management

This repository contains a production-grade Docker Compose infrastructure for a homeserver, organized into 14 granular stacks.

## Quick Start

```bash
# Validate all configurations
make validate

# Start core services
make start-core

# Start all services
make start-all

# View running containers
make ps
```

## Stack Organization

| Stack           | Services                            | Purpose                   |
| --------------- | ----------------------------------- | ------------------------- |
| `network`       | Tailscale, Traefik, Whoami, AdGuard | Network infrastructure    |
| `dbs`           | Postgres, Redis                     | Shared databases          |
| `auth`          | Authelia                            | Authentication            |
| `monitoring`    | Beszel, Uptime Kuma                 | Infrastructure monitoring |
| `photos`        | Immich                              | Photo management          |
| `media`         | Jellyfin                            | Media server              |
| `bookmarks`     | Hoarder                             | Bookmark manager          |
| `dashboard`     | Glance                              | Dashboard                 |
| `notes`         | Livesync (CouchDB)                  | Note synchronization      |
| `documents`     | Paperless-ngx                       | Document management       |
| `chat`          | Open WebUI                          | LLM chat interface        |
| `finance`       | Maybe                               | Finance management        |
| `notifications` | Gotify                              | Notification server       |
| `containers`    | Portainer                           | Container management      |
| `wiki`          | Quartz                              | Wiki/documentation        |

## Common Operations

### Starting Stacks

```bash
make start-core              # Start network, dbs, auth
make start-photos            # Start specific stack
make start-all               # Start everything
```

### Stopping Stacks

```bash
make stop-photos             # Stop specific stack
make stop-all                # Stop everything
```

### Maintenance

```bash
make logs-photos             # View logs
make restart-photos          # Restart stack
make pull-all                # Pull latest images
make update-photos           # Pull and restart
```

### Validation & Testing

```bash
make validate                # Validate all configs
make lint                    # Run linting
make security                # Security scans
make test                    # Run all checks
```

## Configuration

### Global Variables

Edit `.env.global` for shared configuration:

- Domain names
- Admin credentials
- API keys
- Timezone

### Stack-Specific Variables

Each stack has its own `.env` file for:

- Service versions
- Stack-specific secrets
- Custom paths

## CI/CD

GitHub Actions automatically run on pull requests:

- ✅ Docker Compose validation
- ✅ YAML linting
- ✅ Shell script validation
- ✅ Secret scanning
- ✅ Security scanning
- ✅ Environment file validation

## Directory Structure

```
homeserver/
├── .github/
│   ├── workflows/          # GitHub Actions
│   └── scripts/            # Validation scripts
├── network/                # Network stack
│   ├── compose.yaml
│   ├── .env
│   └── traefik.yaml
├── dbs/                    # Database stack
│   ├── compose.yaml
│   ├── .env
│   └── postgres/
├── [other stacks...]
├── .env.global             # Global configuration
├── Makefile                # Management commands
└── README.md
```

## Production Best Practices

✅ **Version Pinning**: All images use versioned tags
✅ **Variabilization**: All configs use environment variables
✅ **Security**: Secrets in .env files (gitignored)
✅ **Monitoring**: Health checks and logging
✅ **Validation**: Automated CI/CD checks
✅ **Documentation**: Comprehensive docs and examples

## License

MIT
