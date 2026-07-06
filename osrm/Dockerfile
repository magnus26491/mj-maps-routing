# OSRM (Open Source Routing Machine) Dockerfile
# ============================================
# This service provides car routing capabilities for the mj-maps-systems API.
#
# DEPLOYMENT: Railway - select "osrm/" directory when linking repo
# - Service name: osrm
# - Internal URL: http://osrm.railway.internal:5000
# - Volume mount: /data (5 GB minimum)
# - RAM: 6 GB for first-start processing, 2 GB ongoing
#
# FIRST START: ~20-30 minutes (downloads England PBF, processes map data)
# SUBSEQUENT STARTS: <30 seconds (loads processed data from volume)
#
# The entrypoint.sh handles one-time data preparation on first run.
# Processed data persists in the /data volume across restarts.

FROM osrm/osrm-backend:latest

# Install wget for downloading OSM extracts
RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g; s|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y wget ca-certificates --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Copy and set up entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Railway exposes port 5000 for the OSRM HTTP server
EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]
