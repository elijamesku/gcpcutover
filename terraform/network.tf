# ******************************************************************************
# The foundation of the migration
# ******************************************************************************
# Everything lives inside the VPC (Virtual Private Cloud)
# networking
# ******************************************************************************

# -----------------------------------------------------------------------------
# VPC Network
# -----------------------------------------------------------------------------
# The isolated network. All Compute Engine VMs, Cloud SQL (with
# private IP), and GKE nodes will use this network. In this case, the same
# VPC has a subnet that receives traffic from on-prem via VPN.
# -----------------------------------------------------------------------------
resource "google_compute_network" "migration_vpc" {
  name                    = "migration-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  # auto_create_subnetworks = false means WE define subnets (recommended for
  # enterprises to control IP ranges and regional placement).
  # routing_mode = GLOBAL: routes are global (default). REGIONAL is for
  # legacy / specific use cases.
  depends_on = [google_project_service.compute]
}

# -----------------------------------------------------------------------------
# Subnets (Regional)
# -----------------------------------------------------------------------------
# Each subnet has a CIDR range (e.g. 10.0.1.0/24 = 256 IPs). 
# We create one subnet per region for the migration workload.
# -----------------------------------------------------------------------------
resource "google_compute_subnetwork" "migration_subnet" {
  name          = "migration-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.migration_vpc.id

  # Optional: private Google access lets VMs with only private IPs reach
  # Google APIs (e.g. Cloud Storage) without a public IP. Used in locked-down
  # environments.
  private_ip_google_access = true
}

# -----------------------------------------------------------------------------
# Firewall Rules
# -----------------------------------------------------------------------------
# In GCP, firewall rules are stateful and apply at the VM level (not subnet).
# Default: "default" network has allow egress, deny ingress. We add explicit
# rules to allow SSH to a VM (if created) and allow internal traffic.
# -----------------------------------------------------------------------------

# Allow SSH from anywhere (for learning). In production restrict to
# IAP or a bastion IP.
resource "google_compute_firewall" "allow_ssh" {
  name    = "migration-allow-ssh"
  network = google_compute_network.migration_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["migration-vm"]
}

# Allow internal traffic across all migration subnets (app, DB, GKE, compute).
resource "google_compute_firewall" "allow_internal" {
  name    = "migration-allow-internal"
  network = google_compute_network.migration_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [
    google_compute_subnetwork.migration_subnet.ip_cidr_range,
    google_compute_subnetwork.gke_subnet.ip_cidr_range,
    google_compute_subnetwork.compute_subnet.ip_cidr_range,
  ]
}

# Allow traffic from legacy (peered) for migration/transfer
resource "google_compute_firewall" "allow_from_legacy" {
  name    = "migration-allow-from-legacy"
  network = google_compute_network.migration_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [google_compute_subnetwork.legacy_subnet.ip_cidr_range]
}

# -----------------------------------------------------------------------------
# Additional subnets for migration target tiers
# -----------------------------------------------------------------------------
# migration-subnet: landing/transfer workloads (existing)
# gke-subnet: GKE node and pod/service IPs
# compute-subnet: lift-and-shift VMs
# DB uses private service connection (separate reserved range)
# -----------------------------------------------------------------------------

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.migration_vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/20"
  }
}

resource "google_compute_subnetwork" "compute_subnet" {
  name          = "compute-subnet"
  ip_cidr_range = "10.0.4.0/24"
  region        = var.region
  network       = google_compute_network.migration_vpc.id
  private_ip_google_access = true
}
