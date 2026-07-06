#!/bin/bash
# Valhalla Service Entrypoint
# ===========================
# This script handles:
# 1. First-run: Builds Valhalla config, downloads England PBF, creates:
#    - Admin database (boundaries for routing restrictions)
#    - Timezone database (for arrival time estimates)
#    - Routing tiles (the actual graph data)
# 2. Subsequent runs: Skips all processing and starts the service directly
#
# IMPORTANT: First run takes 15-25 minutes just for tile building.
# If Railway kills the process mid-build, the next start safely re-processes.
# Only the final output files indicate a complete build.
#
# OUTPUT FILES (stored in /data volume):
# - valhalla.json: Service configuration
# - valhalla_tiles/: Directory containing routing graph tiles
# - valhalla_tiles.tar: Compressed tile extract for fast loading
# - timezones.sqlite: Timezone lookup database
# - admins.sqlite: Administrative boundaries database

set -e

DATA="/data"
TILES="$DATA/valhalla_tiles"
CONFIG="$DATA/valhalla.json"
PBF="$DATA/england.osm.pbf"

if [ ! -f "$CONFIG" ]; then
  echo "[valhalla] First start — building config..."
  mkdir -p "$TILES"

  # Generate Valhalla service configuration with tile directories and limits
  valhalla_build_config \
    --mjolnir-tile-dir "$TILES" \
    --mjolnir-tile-extract "$TILES/valhalla_tiles.tar" \
    --mjolnir-timezone "$TILES/timezones.sqlite" \
    --mjolnir-admin "$TILES/admins.sqlite" \
    --service-limits-auto-close true \
    > "$CONFIG"

  echo "[valhalla] Downloading England extract (~700 MB)..."
  wget -q -O "$PBF" \
    https://download.geofabrik.de/europe/great-britain/england-latest.osm.pbf

  echo "[valhalla] Building admin db..."
  valhalla_build_admins --config "$CONFIG" "$PBF"

  echo "[valhalla] Building timezone db..."
  valhalla_build_timezones "$CONFIG"

  echo "[valhalla] Building tiles (this takes 15–25 min on first run)..."
  valhalla_build_tiles --config "$CONFIG" "$PBF"

  echo "[valhalla] Building extract..."
  valhalla_build_extract --config "$CONFIG" --verbosity INFO

  # Clean up PBF file after successful tile building
  rm -f "$PBF"
  echo "[valhalla] Done. Tiles stored in volume."
fi

echo "[valhalla] Starting service..."
exec valhalla_service "$CONFIG" 1
