# mj-maps-routing

Routing services for [mj-maps-systems](https://github.com/magnus26491/mj-maps-systems). This repository contains Docker configurations for OSRM and Valhalla routing engines, deployed on Railway.

## Architecture

```
mj-maps-systems (API)
    │
    ├── OSRM (osrm.railway.internal:5000)  ← Car routing
    └── Valhalla (valhalla.railway.internal:8002)  ← HGV routing
```

## Services

### OSRM (Open Source Routing Machine)
- **Purpose**: Car routing, distance matrices
- **Data**: England-only OSM extract (great-britain/england)
- **Port**: 5000
- **First deploy**: ~20-30 minutes (download + process)
- **Volume**: 5 GB minimum

### Valhalla
- **Purpose**: HGV (Heavy Goods Vehicle) routing with turn-by-turn navigation
- **Data**: England-only OSM extract
- **Port**: 8002
- **First deploy**: ~25-40 minutes (admin db + timezone + tiles)
- **Volume**: 8 GB minimum

## Deployment

Deploy each service on Railway by linking this repo and selecting the appropriate subdirectory:
- Select `osrm/` for the OSRM service
- Select `valhalla/` for the Valhalla service

## Environment Variables (mj-maps-systems API)

```bash
OSRM_URL=http://osrm.railway.internal:5000
VALHALLA_URL=http://valhalla.railway.internal:8002
```
