# ******************************************************************************
# GKE — Migration target for containerized / refactored workloads
# ******************************************************************************
# Applications will be moving from VMs to containers and run on
# Google Kubernetes Engine inside of pods > Nodes. This cluster lives in the migration
# VPC and uses the dedicated gke-subnet (with pod/service secondary ranges).
# ******************************************************************************

resource "google_container_cluster" "migration" {
  name     = "migration-gke"
  location = var.region

  # Regional cluster optional; use location = var.region for zonal (single zone).
  # For production use a regional cluster (e.g. us-central1) for HA.
  node_locations = ["${var.region}-a"]

  network    = google_compute_network.migration_vpc.name
  subnetwork = google_compute_subnetwork.gke_subnet.name

  # VPC-native (alias IP) cluster — required when using secondary ranges for pods/services
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  depends_on = [
    google_project_service.container,
    google_compute_subnetwork.gke_subnet
  ]
}

resource "google_container_node_pool" "migration_pool" {
  name       = "migration-pool"
  location   = var.region
  cluster    = google_container_cluster.migration.name
  node_count = var.gke_node_count

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags = ["gke-migration"]
  }
}
