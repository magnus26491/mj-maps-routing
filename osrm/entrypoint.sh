#!/bin/bash
# OSRM Service Entrypoint
# ========================
# This script handles:
# 1. First-run: Downloads England OSM extract (~700 MB) and processes it
# 2. Subsequent runs: Skips processing and starts the server directly
#
# The check for $OSRM file (processed data) ensures idempotent restarts.
# If the build is killed mid-processing, the next start will re-process safely.
#
# OUTPUT FILES (stored in /data volume):
# - england.osrm: Processed routing data for car profile

set -e

DATA="/data"
PBF="$DATA/england.osm.pbf"
OSRM="$DATA/england.osrm"

if [ ! -f "$OSRM" ]; then
  echo "[osrm] First start — downloading England extract (~700 MB)..."
  wget -q -O "$PBF" \
    https://download.geofabrik.de/europe/great-britain/england-latest.osm.pbf

  echo "[osrm] Extracting (using car profile)..."
  osrm-extract -p /opt/car.lua "$PBF"

  echo "[osrm] Partitioning..."
  osrm-partition "$OSRM"

  echo "[osrm] Customising..."
  osrm-customize "$OSRM"

  # Clean up PBF file after successful processing
  rm -f "$PBF"
  echo "[osrm] Done. Processed data stored in volume."
fi

echo "[osrm] Starting server..."
exec osrm-routed \
  --algorithm=MLD \
  --max-table-size=1000 \
  --max-trip-size=1000 \
  "$OSRM"
