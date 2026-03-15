# GCP Data Migration

```
 ____ ___ __  __    _  _____ _____
 / ___|_ _|  \/  |  / \|_   _| ____|
| |   | || |\/| | / _ \ | | |  _|
| |___| || |  | |/ ___ \| | | |___
\____|___|_|  |_/_/   \_\_| |_____|
      migration: legacy → interconnect → landing zone
```

I put this repo together as a **Terraform-based GCP data migration** layout: discovery artifacts, a landing zone (VPC, VPN, Interconnect), GKE, Cloud SQL, Storage Transfer, Secret Manager, and CI/CD. It’s set up so I can run a full plan/apply and get a realistic migration footprint without hardcoding secrets.

## What I’m running

- **Legacy (source):** A second VPC with a VM and firewall to simulate on-prem; peered to the migration VPC.
- **Migration (target):** A single VPC with subnets for general workload, GKE, and compute; HA VPN gateway and Partner Interconnect attachment; firewall rules for SSH and internal traffic.
- **GKE:** One cluster in the migration VPC with a dedicated subnet and secondary ranges for pods/services.
- **Cloud SQL:** Optional PostgreSQL with Private Service Access (I keep it off sometimes to save cost).
- **Storage:** Two buckets (source + destination) and a Storage Transfer job between them.
- **Secrets:** Google Secret Manager; the API is enabled and I use `terraform/secrets.tf` when I need to pull or generate a secret.

## How I use it

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # I set project_id, region, bucket_prefix
gcloud auth application-default login
gcloud config set project MY_PROJECT_ID
terraform init
terraform plan
terraform apply
```

I keep `terraform.tfvars` out of git (it’s in `.gitignore`). When I’m done I run `terraform destroy` from the same directory.

## Layout

```
gcpcutover/
├── terraform/          # All infra: legacy, migration VPC, GKE, Cloud SQL, storage, IAM, secrets
├── docs/
│   ├── SECRETS.md      # How I use Secret Manager with this stack
│   └── discovery/      # Inventory, dependency map, data classification, risk list
├── ci/                 # Cloud Build + GitHub Actions examples
└── scripts/            # simulate-migration.sh and helpers
```

## ASCII: legacy → GCP

```
  [ Legacy VPC ]          [ Migration VPC ]
  - legacy VM            - migration subnet
  - source bucket   ~~>  - GKE subnet (migration-gke)
       peering +         - compute subnet
   VPN / Interconnect    - Cloud SQL (private IP)
                         - destination bucket
                         - Storage Transfer job
```

Discovery docs live in `docs/discovery/`; I update them as the migration scope changes.
