# Valhalla Dockerfile
# ====================
# This service provides HGV (Heavy Goods Vehicle) aware routing with
# turn-by-turn navigation for the mj-maps-systems API.
#
# DEPLOYMENT: Railway - select "valhalla/" directory when linking repo
# - Service name: valhalla
# - Internal URL: http://valhalla.railway.internal:8002
# - Volume mount: /data (8 GB minimum - tiles are larger than OSRM)
# - RAM: 8 GB for first-start processing, 4 GB ongoing
#
# FIRST START: ~25-40 minutes (downloads England PBF, builds tiles, admin/tz dbs)
# SUBSEQUENT STARTS: Fast startup, loads pre-built tiles from volume
#
# The entrypoint.sh handles all one-time tile preparation on first run.
# Built tiles persist in the /data volume across restarts.

FROM ghcr.io/valhalla/valhalla:run-latest

USER root

# Install utilities for downloading OSM data and health checks
RUN apt-get update && apt-get install -y wget curl && rm -rf /var/lib/apt/lists/*

# Copy and set up entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Railway exposes port 8002 for Valhalla's HTTP server
EXPOSE 8002

ENTRYPOINT ["/entrypoint.sh"]
