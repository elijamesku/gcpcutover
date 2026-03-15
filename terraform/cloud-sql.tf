# =============================================================================
# Cloud SQL — Migration target for database workloads
# =============================================================================
# Database Migration Service (DMS) replicates from on-prem or other clouds into
# Cloud SQL. This instance is the target: private IP only, in the migration VPC.
# Private IP requires a reserved range and Private Service Access (peering to
# Google's services).
# =============================================================================

# Reserved range for Private Service Access (Cloud SQL, etc.)
resource "google_compute_global_address" "private_ip_range" {
  count         = var.enable_cloud_sql ? 1 : 0
  name          = "cloud-sql-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.migration_vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count                   = var.enable_cloud_sql ? 1 : 0
  network                 = google_compute_network.migration_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range[0].name]
}

resource "google_sql_database_instance" "migration_target" {
  count            = var.enable_cloud_sql ? 1 : 0
  name             = "migration-sql-target"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.migration_vpc.id
    }

    backup_configuration {
      enabled            = true
      start_time         = "03:00"
      point_in_time_recovery_enabled = false
    }
  }

  deletion_protection = false
  depends_on          = [google_service_networking_connection.private_vpc_connection]
}
