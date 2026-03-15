# Data Classification

**Purpose:** Classify data by sensitivity, retention, and residency so the migration and target design meet security and compliance. Affects encryption, IAM, storage class, and region.

**How to use:** One row per dataset or system. Align with the org classification scheme (e.g. Public, Internal, Confidential, Restricted).

| Dataset / system | Classification | Retention | Residency / region | Encryption requirements | Notes |
|------------------|----------------|-----------|--------------------|--------------------------|-------|
| migration-source / destination buckets | Internal | Per policy | Single region (var.region) | At rest (GCP default); in transit TLS | Object migration target; versioning on dest |
| Cloud SQL (migration-sql-target) | Internal / Confidential | Per policy | Same region as VPC | At rest + in transit; private IP only | DB migration target; no public IP |
| GKE workload data | Internal | Per policy | Same region | Default GCP + in-transit TLS | Container workloads; node pools in migration VPC |
| Legacy VM / app data | Internal | Per policy | Legacy VPC → migration VPC | Same after migration | Lift-and-shift; no CMEK in this demo |

**Classification** – Public, Internal, Confidential, Restricted.  
**Retention** – How long data must be kept; drives lifecycle rules and backups.  
**Residency** – Country/region constraints (e.g. EU only, US only).  
**Encryption** – Default GCP vs. CMEK (customer-managed keys) or HSM.
