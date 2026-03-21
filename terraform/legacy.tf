# *****************************************************************************
# LEGACY
# *****************************************************************************
# This is the data center.
# The second VPC: legacy workloads (VM, file store) live here.
# Connectivity to the migration (target) VPC is via VPC Peering + Cloud VPN
# gateway in migration VPC (where production VPN/Interconnect will land)
# *****************************************************************************

resource "google_compute_network" "legacy_vpc" {
  name                    = "legacy-vpc"
  auto_create_subnetworks  = false
  routing_mode             = "GLOBAL"
  depends_on               = [google_project_service.compute]
}

resource "google_compute_subnetwork" "legacy_subnet" {
  name          = "legacy-subnet"
  ip_cidr_range = "192.168.1.0/24"
  region        = var.region
  network       = google_compute_network.legacy_vpc.id
  private_ip_google_access = true
}

# Legacy app VM app server
resource "google_compute_instance" "legacy_vm" {
  name         = "legacy-app-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  tags         = ["legacy-vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    subnetwork  = google_compute_subnetwork.legacy_subnet.id
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Legacy app VM - on-prem" > /tmp/legacy.txt
  EOT
  allow_stopping_for_update = true
}

# Firewall: allow SSH and internal
resource "google_compute_firewall" "legacy_allow_ssh" {
  name    = "legacy-allow-ssh"
  network = google_compute_network.legacy_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["legacy-vm"]
}

resource "google_compute_firewall" "legacy_allow_internal" {
  name    = "legacy-allow-internal"
  network = google_compute_network.legacy_vpc.name
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
  source_ranges = [google_compute_subnetwork.legacy_subnet.ip_cidr_range]
}

# VPC Peering: legacy <-> migration (so "source" and "target" can have comms)
resource "google_compute_network_peering" "legacy_to_migration" {
  name         = "legacy-to-migration"
  network      = google_compute_network.legacy_vpc.id
  peer_network = google_compute_network.migration_vpc.id
}

resource "google_compute_network_peering" "migration_to_legacy" {
  name         = "migration-to-legacy"
  network      = google_compute_network.migration_vpc.id
  peer_network = google_compute_network.legacy_vpc.id
}
