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

set -euo pipefail

DATA="/data"
PBF="$DATA/england.osm.pbf"
OSRM="$DATA/england.osrm"

mkdir -p "$DATA"

if [ ! -f "$OSRM" ]; then
  # Clean up any partial download from a previous failed run
  rm -f "$PBF"

  echo "[osrm] First start — downloading England extract (~700 MB)..."
  if ! wget --progress=dot:giga -O "$PBF" \
    https://download.geofabrik.de/europe/great-britain/england-latest.osm.pbf; then
    echo "[osrm] ERROR: download failed. Check network access to download.geofabrik.de"
    rm -f "$PBF"
    exit 1
  fi

  echo "[osrm] Extracting (car profile)..."
  osrm-extract -p /opt/car.lua "$PBF"

  echo "[osrm] Partitioning..."
  osrm-partition "$OSRM"

  echo "[osrm] Customising..."
  osrm-customize "$OSRM"

  rm -f "$PBF"
  echo "[osrm] Processing complete. Data stored in volume."
fi

echo "[osrm] Starting server on :5000..."
exec osrm-routed \
  --algorithm=MLD \
  --max-table-size=1000 \
  --max-trip-size=1000 \
  --port 5000 \
  "$OSRM"
