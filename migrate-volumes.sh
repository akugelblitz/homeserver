#!/bin/bash
# Volume Migration Script
# This script migrates data from old volume names to new stack-prefixed volumes

set -e

echo "=== Homeserver Volume Migration Script ==="
echo "This will migrate data from old volumes to new stack-prefixed volumes"
echo ""

# Define volume mappings (old_volume:new_volume)
declare -A VOLUME_MAP=(
    ["backbone_tailscale_data"]="network_tailscale_data"
    ["backbone_traefik_certs"]="network_traefik_certs"
    ["backbone_adguard_data"]="network_adguard_data"
    ["backbone_postgres_data"]="dbs_postgres_data"
    ["backbone_redis_data"]="dbs_redis_data"
    ["admin_beszel_data"]="monitoring_beszel_data"
    ["admin_uptime_kuma_data"]="monitoring_uptime_kuma_data"
    ["user_immich_model_cache"]="photos_immich_model_cache"
    ["user_immich_db_data"]="photos_immich_db_data"
    ["user_jellyfin_config"]="media_jellyfin_config"
    ["user_jellyfin_cache"]="media_jellyfin_cache"
    ["user_hoarder_data"]="bookmarks_hoarder_data"
    ["user_hoarder_meilisearch"]="bookmarks_hoarder_meilisearch"
    ["user_livesync_data"]="notes_livesync_data"
    ["user_paperless_data"]="documents_paperless_data"
    ["user_open_webui_data"]="chat_open_webui_data"
    ["user_maybe_data"]="finance_maybe_data"
    ["admin_portainer_data"]="containers_portainer_data"
)

echo "Step 1: Creating new volumes..."
for new_volume in "${VOLUME_MAP[@]}"; do
    if docker volume inspect "$new_volume" &>/dev/null; then
        echo "  ✓ Volume $new_volume already exists"
    else
        docker volume create "$new_volume"
        echo "  ✓ Created volume $new_volume"
    fi
done

echo ""
echo "Step 2: Migrating data..."
for old_volume in "${!VOLUME_MAP[@]}"; do
    new_volume="${VOLUME_MAP[$old_volume]}"

    # Check if old volume exists
    if ! docker volume inspect "$old_volume" &>/dev/null; then
        echo "  ⚠ Skipping $old_volume (doesn't exist)"
        continue
    fi

    echo "  → Migrating $old_volume to $new_volume..."
    docker run --rm \
        -v "$old_volume:/source:ro" \
        -v "$new_volume:/dest" \
        alpine sh -c "cd /source && cp -av . /dest"
    echo "  ✓ Migrated $old_volume to $new_volume"
done

echo ""
echo "=== Migration Complete ==="
echo "All volumes have been migrated successfully!"
echo ""
echo "Next steps:"
echo "1. Start the network stack: cd /home/aditya/homeserver/network && docker compose up -d"
echo "2. Start the dbs stack: cd /home/aditya/homeserver/dbs && docker compose up -d"
echo "3. Start the auth stack: cd /home/aditya/homeserver/auth && docker compose up -d"
echo "4. Start remaining stacks as needed"
