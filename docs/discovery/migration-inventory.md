# Migration Inventory

**Purpose:** Single source of truth for what is in scope to migrate—systems, data volume, type, and priority. Use this to size the effort and order migration waves.

**How to use:** One row per system or data store. Re-run discovery tools (e.g. Cloud Migrate, scripts, scans) and update regularly.

| System / asset name | Type | Location (on-prem / cloud) | Data size (est.) | Owner / app | Migration priority | Target in GCP | Notes |
|---------------------|------|----------------------------|------------------|------------|--------------------|---------------|-------|
| legacy-app-vm | VM / compute | Legacy VPC (sim. on-prem) | N/A | App team | P2 | Compute Engine (compute-subnet) | Simulated on-prem app server; lift-and-shift |
| migration-source bucket | Object storage | Legacy / same project | Variable | Data team | P1 | Cloud Storage (destination bucket) | File/docs migration via Storage Transfer |
| (Simulated) MySQL/PostgreSQL | Database | Legacy / on-prem | ~50 GB | App team | P1 | Cloud SQL (migration-sql-target) | DMS replicates into Cloud SQL |
| Batch / ETL job | VM or container | Legacy VPC | N/A | Analytics | P3 | GKE (migration-gke) | Refactor to container on GKE |
| migration-demo-vm | VM (optional) | Migration VPC | N/A | Platform | P3 | Compute Engine (compute-subnet) | Lift-and-shift target; enable_compute = true |

**Type** – File share, Object (S3/GCS), MySQL, PostgreSQL, SQL Server, Oracle, VM, Container.  
**Migration priority** – P1 (critical, first wave) through P3 (later or optional).  
**Target in GCP** – Cloud Storage, Cloud SQL, Compute Engine, GKE, BigQuery.
