# Centralized Environment Configuration

I've created a centralized configuration system for your homeserver stacks:

## Solution

### 1. Global Configuration File

Created [`.env.global`](file:///home/aditya/homeserver/.env.global) containing all shared variables:

- Global settings (TZ, ROOT_FQDN, HOSTNAME, etc.)
- Admin credentials
- Cloudflare tokens
- Tailscale auth key
- Database credentials
- GitHub token

### 2. How It Works

Docker Compose reads `.env` files automatically, but doesn't natively support sourcing from parent directories. However, you have two approaches:

#### **Option A: Manual Approach (Recommended)**

Keep the current structure but remove duplicate variables from individual stack `.env` files. When you need to reference a global variable:

1. Edit `.env.global` for global changes
2. Individual stack `.env` files only contain stack-specific variables
3. Use symlinks or includes where needed

#### **Option B: Compose File References**

Modify each `compose.yaml` to explicitly reference the global env file:

```yaml
services:
  service_name:
    env_file:
      - ../.env.global # Global variables
      - .env # Stack-specific overrides
```

### 3. Current Structure

**Global variables** (in `.env.global`):

- `TZ`, `ROOT_FQDN`, `HOSTNAME`, `UID`, `GID`
- `ADMIN_USER`, `ADMIN_EMAIL`, `ADMIN_PASS`
- `CF_API_EMAIL`, `CF_DNS_API_TOKEN`
- `TS_AUTHKEY`
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- `GITHUB_TOKEN`

**Stack-specific variables** (remain in each stack's `.env`):

- `STACK` name
- Service versions (e.g., `TRAEFIK_VERSION`)
- Service-specific secrets (e.g., `OAUTH_CLIENT_SECRET`)
- Service-specific paths (e.g., `IMMICH_UPLOAD_LOCATION`)

## Recommendation

I recommend **Option B** - modifying compose files to use `env_file` with both global and local env files. This gives you:

✅ Single source of truth for global values
✅ Easy updates (change once in `.env.global`)
✅ Stack-specific overrides still work
✅ Clear separation of concerns

Would you like me to:

1. Update all compose files to use the `env_file` approach?
2. Clean up individual `.env` files to remove duplicate global variables?
