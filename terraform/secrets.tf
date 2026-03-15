# ******************************************************************************
# Google Secret Manager — secrets for migration (e.g. Cloud SQL, API keys)
# ******************************************************************************
# Secrets stay out of terraform.tfvars and state. Create secrets in the
# console or gcloud, then reference them here with data sources.
# ******************************************************************************

# -----------------------------------------------------------------------------
# Optional: read an existing secret (e.g. Cloud SQL password)
# -----------------------------------------------------------------------------
# Create the secret first, e.g.:
#   gcloud secrets create cloud-sql-migration --replication-policy="automatic"
#   echo -n "my-db-password" | gcloud secrets versions add cloud-sql-migration --data-file=-
# Then uncomment the data source and use secret_version.secret_data in resources or outputs.
# -----------------------------------------------------------------------------
# data "google_secret_manager_secret_version" "cloud_sql_password" {
#   provider = google
#   secret   = "projects/${var.project_id}/secrets/cloud-sql-migration"
# }
#
# output "db_password_from_secret_manager" {
#   description = "Cloud SQL password from Secret Manager (for gcloud sql users set-password or app config)"
#   value       = data.google_secret_manager_secret_version.cloud_sql_password.secret_data
#   sensitive   = true
# }

# -----------------------------------------------------------------------------
# Optional: create a secret and store a Terraform-generated value
# -----------------------------------------------------------------------------
# Use when Terraform generates the password (e.g. random_password) and we
# want it in Secret Manager for apps; the value is written once at apply.
# If uncommenting, add the random provider to main.tf: hashicorp/random ~> 3.0
# -----------------------------------------------------------------------------
# resource "google_secret_manager_secret" "cloud_sql" {
#   provider  = google
#   secret_id = "cloud-sql-migration"
#   replication { auto {} }
# }
#
# resource "google_secret_manager_secret_version" "cloud_sql" {
#   provider    = google
#   secret      = google_secret_manager_secret.cloud_sql.id
#   secret_data = random_password.db.result
# }
#
# resource "random_password" "db" {
#   length  = 32
#   special = true
# }
