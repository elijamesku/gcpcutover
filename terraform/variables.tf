# =============================================================================
# GCP Data Migration Learning Project - Variables
# =============================================================================
# Variables used to run this in a GCP project without hardcoding.
# Copy terraform.tfvars.example to terraform.tfvars and fill in the
# project ID.
# =============================================================================

variable "project_id" {
  description = "GCP project ID (e.g. my-project-12345)"
  type        = string
}

variable "region" {
  description = "Primary region for resources (e.g. us-central1). Migrations often use one region first."
  type        = string
  default     = "us-central1"
}

variable "enable_compute" {
  description = "Set to true to create a small VM (Compute Engine) for lift-and-shift learning. Costs a few cents/hour."
  type        = bool
  default     = false
}

variable "bucket_prefix" {
  description = "Prefix for Cloud Storage bucket names (must be globally unique). Use project_id or a unique string."
  type        = string
}

# Connectivity (production: set to on-prem VPN endpoint IP)
variable "on_prem_vpn_peer_ip" {
  description = "On-prem VPN gateway public IP for External VPN Gateway resource. Use 203.0.113.1 as placeholder if not connecting."
  type        = string
  default     = "203.0.113.1"
}

# GKE
variable "gke_node_count" {
  description = "Number of nodes per zone in the GKE migration target cluster."
  type        = number
  default     = 1
}

# Cloud SQL (set to false to skip DB target for cost)
variable "enable_cloud_sql" {
  description = "Create Cloud SQL instance as migration target for database workloads."
  type        = bool
  default     = true
}
