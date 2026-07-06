#!/bin/bash
set -euo pipefail


DATA="/data"
PBF="$DATA/united-kingdom.osm.pbf"
OSRM="$DATA/united-kingdom.osrm"


mkdir -p "$DATA"


if [ ! -f "$OSRM" ]; then
  rm -f "$PBF"


  echo "[osrm] First start — downloading United Kingdom extract (~2.1 GB)..."
  if ! wget --progress=dot:giga -O "$PBF" \
    https://download.geofabrik.de/europe/united-kingdom-latest.osm.pbf; then
    echo "[osrm] ERROR: download failed."
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
