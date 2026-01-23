#!/bin/bash
# Update all stack .env files to use centralized global configuration

HOMESERVER_DIR="/home/aditya/homeserver"
GLOBAL_ENV="$HOMESERVER_DIR/.env.global"

echo "=== Updating Stack .env Files ==="
echo "This will update all stack .env files to source global configuration"
echo ""

# Define all stacks
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
    ENV_FILE="$HOMESERVER_DIR/$stack/.env"
    
    if [ -f "$ENV_FILE" ]; then
        echo "Processing $stack/.env..."
        
        # Create backup
        cp "$ENV_FILE" "$ENV_FILE.backup"
        
        # Add source directive at the top if not already present
        if ! grep -q "^# Source global configuration" "$ENV_FILE"; then
            {
                echo "# Source global configuration"
                echo "# Global variables are defined in ../.env.global"
                echo "# Stack-specific overrides below"
                echo ""
                cat "$ENV_FILE"
            } > "$ENV_FILE.tmp"
            mv "$ENV_FILE.tmp" "$ENV_FILE"
        fi
        
        echo "  ✓ Updated $stack/.env"
    fi
done

echo ""
echo "=== Update Complete ==="
echo ""
echo "Global configuration: $GLOBAL_ENV"
echo "Individual stacks can override global values in their .env files"
echo ""
echo "To use global variables, you can:"
echo "1. Keep stack .env files as-is (they override globals)"
echo "2. Remove duplicate variables from stack .env files to use global values"
echo ""
echo "Backups created: <stack>/.env.backup"
