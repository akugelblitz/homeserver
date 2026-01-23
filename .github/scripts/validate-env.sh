#!/bin/bash
# Validate environment files structure and required variables

set -e

echo "=== Environment File Validation ==="
echo ""

ERRORS=0

# Check if .env.global exists
if [ ! -f ".env.global" ]; then
    echo "❌ Missing .env.global file"
    ERRORS=$((ERRORS + 1))
else
    echo "✓ .env.global exists"
fi

# Required global variables
REQUIRED_GLOBAL_VARS=(
    "TZ"
    "ROOT_FQDN"
    "HOSTNAME"
    "ADMIN_USER"
    "ADMIN_EMAIL"
)

echo ""
echo "Checking required global variables..."
for var in "${REQUIRED_GLOBAL_VARS[@]}"; do
    if grep -q "^${var}=" .env.global 2>/dev/null; then
        echo "  ✓ $var defined"
    else
        echo "  ❌ $var missing in .env.global"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check for placeholder values
echo ""
echo "Checking for placeholder values..."
if grep -r "CHANGE_ME\|CHANGE_TO_YOUR_KEY\|YOUR_.*_HERE" --include="*.env" . 2>/dev/null; then
    echo "⚠️  Found placeholder values - these should be replaced before deployment"
    # Don't fail on placeholders, just warn
fi

# Validate each stack has .env file
echo ""
echo "Checking stack .env files..."
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
    if [ -f "$stack/.env" ]; then
        # Check if STACK variable is set correctly
        if grep -q "^STACK=$stack" "$stack/.env"; then
            echo "  ✓ $stack/.env valid"
        else
            echo "  ⚠️  $stack/.env missing STACK=$stack variable"
        fi
    else
        echo "  ❌ $stack/.env missing"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check .env files are in .gitignore
echo ""
echo "Checking .gitignore..."
if [ -f ".gitignore" ]; then
    if grep -q "^\.env$" .gitignore && grep -q "^\.env\.global$" .gitignore; then
        echo "✓ .env files properly ignored"
    else
        echo "⚠️  .env files should be in .gitignore"
    fi
else
    echo "⚠️  No .gitignore file found"
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All environment file validations passed"
    exit 0
else
    echo "❌ Found $ERRORS error(s) in environment files"
    exit 1
fi
