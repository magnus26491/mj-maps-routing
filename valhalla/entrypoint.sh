#!/bin/bash
set -euo pipefail


DATA="/data"
TILES="$DATA/valhalla_tiles"
CONFIG="$DATA/valhalla.json"
PBF="$DATA/united-kingdom.osm.pbf"


mkdir -p "$TILES"


if [ ! -f "$TILES/valhalla_tiles.tar" ]; then
  rm -f "$PBF" "$CONFIG"


  echo "[valhalla] First start — building config..."
  valhalla_build_config \
    --mjolnir-tile-dir "$TILES" \
    --mjolnir-tile-extract "$TILES/valhalla_tiles.tar" \
    --mjolnir-timezone "$TILES/timezones.sqlite" \
    --mjolnir-admin "$TILES/admins.sqlite" \
    --service-limits-auto-close true \
    > "$CONFIG"


  echo "[valhalla] Downloading United Kingdom extract (~2.1 GB)..."
  if ! wget --progress=dot:giga -O "$PBF" \
    https://download.geofabrik.de/europe/united-kingdom-latest.osm.pbf; then
    echo "[valhalla] ERROR: download failed."
    rm -f "$PBF"
    exit 1
  fi


  echo "[valhalla] Building admin db..."
  valhalla_build_admins --config "$CONFIG" "$PBF"


  echo "[valhalla] Building timezone db..."
  valhalla_build_timezones "$CONFIG"


  echo "[valhalla] Building tiles (30–45 min)..."
  valhalla_build_tiles --config "$CONFIG" "$PBF"


  echo "[valhalla] Building extract..."
  valhalla_build_extract --config "$CONFIG" --verbosity INFO


  rm -f "$PBF"
  echo "[valhalla] Done. Tiles stored in volume."
fi


echo "[valhalla] Starting service..."
exec valhalla_service "$CONFIG" 1
