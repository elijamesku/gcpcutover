# =============================================================================
# Outputs — Use after apply for migration runbooks and CI/CD
# =============================================================================

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "Primary region"
  value       = var.region
}

# Legacy (source) side
output "legacy_vpc_name" {
  description = "Legacy/source VPC name"
  value       = google_compute_network.legacy_vpc.name
}

output "legacy_vm_name" {
  description = "Legacy app VM name (simulated on-prem)"
  value       = google_compute_instance.legacy_vm.name
}

# Migration (target) side
output "migration_vpc_name" {
  description = "Migration (target) VPC name"
  value       = google_compute_network.migration_vpc.name
}

output "gke_cluster_name" {
  description = "GKE migration target cluster name"
  value       = google_container_cluster.migration.name
}

output "gke_cluster_endpoint" {
  description = "GKE API endpoint (for kubectl)"
  value       = google_container_cluster.migration.endpoint
  sensitive   = true
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL instance connection name (for DMS / app config)"
  value       = var.enable_cloud_sql ? google_sql_database_instance.migration_target[0].connection_name : "Cloud SQL disabled"
}

output "source_bucket" {
  description = "Source bucket (object migration)"
  value       = google_storage_bucket.source.name
}

output "destination_bucket" {
  description = "Destination bucket (migration target)"
  value       = google_storage_bucket.destination.name
}

output "transfer_job_name" {
  description = "Storage Transfer Job name"
  value       = google_storage_transfer_job.source_to_dest.name
}

# Connectivity
output "vpn_gateway_id" {
  description = "HA VPN gateway (migration VPC) — on-prem tunnel lands here"
  value       = google_compute_ha_vpn_gateway.migration_vpn_gateway.id
}

output "interconnect_attachment_name" {
  description = "Partner Interconnect VLAN attachment name"
  value       = google_compute_interconnect_attachment.partner.name
}

output "migration_vm_ssh" {
  description = "SSH to lift-and-shift target VM (if enable_compute = true)"
  value       = var.enable_compute ? "gcloud compute ssh ${google_compute_instance.migration_vm[0].name} --zone=${var.region}-a --project=${var.project_id}" : "N/A (enable_compute = true to create)"
}
