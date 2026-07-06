# Agent Context for mj-maps-routing

## Repository Purpose

This repository contains Docker configurations for two routing engines used by the mj-maps-systems API:
- **OSRM**: Car routing, distance matrix calculations
- **Valhalla**: HGV (Heavy Goods Vehicle) routing with turn-by-turn navigation

Both services are deployed on Railway and communicate over Railway's private internal network.

## Important Notes for Agents

### First-Run Processing Time
Both services perform intensive one-time processing on their first deployment:
- **OSRM**: ~20-30 minutes (downloads ~700MB PBF, partitions, customizes)
- **Valhalla**: ~25-40 minutes (builds admin db, timezone db, and routing tiles)

If Railway kills a container during first-run processing:
1. **This is safe** - the entrypoint checks for final output files before processing
2. The next start will simply resume/re-process from scratch
3. Only the `/data` volume data indicates a successful build

### Railway Deployment
- Do NOT deploy this as a single monorepo service
- Each subdirectory (osrm/, valhalla/) must be deployed as a **separate Railway service**
- When linking the GitHub repo to Railway, specify the subdirectory path

### Memory Requirements
| Service | First-Run RAM | Ongoing RAM |
|---------|---------------|-------------|
| OSRM    | 6 GB          | 2 GB        |
| Valhalla| 8 GB          | 4 GB        |

Set resources high for first deploy, then scale down after volume is populated.

### Internal Network URLs (Railway)
- OSRM: `http://osrm.railway.internal:5000`
- Valhalla: `http://valhalla.railway.internal:8002`

These URLs work from other Railway services but NOT from external traffic.

### Volume Mounts
Both services require persistent `/data` volumes:
- **OSRM**: 5 GB minimum
- **Valhalla**: 8 GB minimum

### OSM Data Coverage
Currently configured for **England only** (great-britain/england extract from Geofabrik).
To expand coverage, modify the `wget` URLs in both entrypoint.sh files.

### Making Changes
After modifying any file:
1. Commit changes to the appropriate branch
2. Railway auto-deploys on push to linked branch
3. First-run processing will NOT re-trigger if volume data exists
4. To force re-processing, delete the volume data in Railway dashboard

## API Integration Points

The mj-maps-systems API uses these endpoints:

### OSRM
- Route calculation: `GET /route/v1/driving/{coords}`
- Distance matrix: `GET /table/v1/driving/{coords}`

### Valhalla
- Route with turn-by-turn: `POST /route`
- Location lookup: `POST /locate`

Both services are called internally by the API - no external access required.
