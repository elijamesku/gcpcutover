# Dependency Map

**Purpose:** Shows which systems depend on which. Migration order must respect dependencies (e.g. migrate DB before apps that use it, or migrate together in one wave).

**How to use:** List dependencies as "Upstream → Downstream" (downstream depends on upstream). Order migration so upstream is available in GCP before or with downstream.

## Dependency list

| Upstream (migrate first or with) | Downstream (depends on) | Dependency type | Notes |
|----------------------------------|-------------------------|------------------|-------|
| Cloud SQL (migration-sql-target) | legacy-app-vm / app | App → DB | App connects to DB; migrate DB via DMS first, then point app at Cloud SQL private IP. |
| Source bucket / file share | legacy-app-vm / app | App → storage | App reads config or assets from object storage; migrate objects via Storage Transfer first. |
| migration-source bucket | Storage Transfer Job | Transfer | Job copies source → destination bucket (same project or cross-cloud). |
| Migration VPC + VPN/Interconnect | All targets | Connectivity | On-prem connects via VPN or Partner Interconnect to migration VPC; all targets live in this VPC. |
| GKE cluster (migration-gke) | Batch / ETL container | Refactor | Containerized workloads deploy to GKE after cluster is up. |

## Architecture (this project)

```
  LEGACY (sim. on-prem)              CONNECTIVITY                 MIGRATION (GCP target)
  ─────────────────────             ─────────────                 ─────────────────────

  [legacy-app-vm]                    VPC Peering                   [migration-demo-vm]  (Compute)
        │                            (or VPN/Interconnect              │
        │                             in production)                   │
        ├──► [source bucket] ──────── Storage Transfer ──────────► [destination bucket]  (GCS)
        │                                                                  │
        └──► (sim. MySQL) ────────── Database Migration Service ──► [Cloud SQL]
                                                                         │
  [Batch / ETL] ─────────────────── Refactor to containers ──────► [GKE cluster]
```

**Dependency type** – App→DB, App→storage, Batch→DB, Replication source→replica, Connectivity.
