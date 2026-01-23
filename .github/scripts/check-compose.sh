#!/bin/bash
# Validate all Docker Compose files

set -e

echo "=== Docker Compose Validation ==="
echo ""

ERRORS=0
STACKS=(
    "network"
    "dbs"
    "auth"
    "monitoring"
    "photos"
    "media"
    "bookmarks"
    "dashboard"
    "notes"
    "documents"
    "chat"
    "finance"
    "notifications"
    "containers"
    "wiki"
)

for stack in "${STACKS[@]}"; do
    if [ -f "$stack/compose.yaml" ]; then
        echo "Validating $stack/compose.yaml..."

        cd "$stack"

        # Validate compose file syntax
        if docker compose config > /dev/null 2>&1; then
            echo "  ✓ $stack compose file is valid"
        else
            echo "  ❌ $stack compose file has errors"
            docker compose config
            ERRORS=$((ERRORS + 1))
        fi

        # Check for external network reference (except network stack)
        if [ "$stack" != "network" ]; then
            if grep -q "external: true" compose.yaml; then
                echo "  ✓ $stack uses external network"
            else
                echo "  ⚠️  $stack should use external network"
            fi
        fi

        # Check for version pinning
        if grep -q '\${.*VERSION' compose.yaml; then
            echo "  ✓ $stack uses version variables"
        else
            echo "  ⚠️  $stack should use version variables for images"
        fi

        cd ..
    else
        echo "⚠️  No compose.yaml found in $stack"
    fi
    echo ""
done

if [ $ERRORS -eq 0 ]; then
    echo "✅ All compose files validated successfully"
    exit 0
else
    echo "❌ Found $ERRORS error(s) in compose files"
    exit 1
fi
