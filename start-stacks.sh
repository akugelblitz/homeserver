#!/bin/bash
# Stack Verification and Startup Script

set -e

echo "=== Homeserver Stack Verification ==="
echo ""

# Define stacks in dependency order
CORE_STACKS=("network" "dbs" "auth")
OPTIONAL_STACKS=("monitoring" "photos" "media" "bookmarks" "dashboard" "notes")
COMMENTED_STACKS=("documents" "chat" "finance" "notifications" "containers" "wiki")

cd /home/aditya/homeserver

echo "Step 1: Validating compose files..."
for stack in "${CORE_STACKS[@]}" "${OPTIONAL_STACKS[@]}"; do
    echo "  → Validating $stack..."
    cd "$stack"
    if docker compose config > /dev/null 2>&1; then
        echo "  ✓ $stack configuration valid"
    else
        echo "  ✗ $stack configuration INVALID"
        docker compose config
        exit 1
    fi
    cd ..
done

echo ""
echo "Step 2: Starting core stacks (network, dbs, auth)..."
for stack in "${CORE_STACKS[@]}"; do
    echo "  → Starting $stack..."
    cd "$stack"
    docker compose up -d
    echo "  ✓ $stack started"
    cd ..
    sleep 5
done

echo ""
echo "Step 3: Waiting for services to be healthy..."
sleep 15

echo ""
echo "Step 4: Checking service status..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=== Core Stacks Started Successfully ==="
echo ""
echo "Optional stacks available:"
for stack in "${OPTIONAL_STACKS[@]}"; do
    echo "  - $stack: cd /home/aditya/homeserver/$stack && docker compose up -d"
done

echo ""
echo "Commented stacks (need configuration):"
for stack in "${COMMENTED_STACKS[@]}"; do
    echo "  - $stack: cd /home/aditya/homeserver/$stack && docker compose up -d"
done
