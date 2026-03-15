# =============================================================================
# CLOUD STORAGE - Where File/Object Data Lands in GCP
# =============================================================================
# In migrations, file data (documents, images, backups) typically moves to
# Google Cloud Storage (GCS). GCS is object storage (like S3). Structure:
#   Project → Bucket (globally unique name) → Objects (files)
#
# We create two buckets to simulate:
#   - "Source" bucket (simulates data being migrated FROM - e.g. on-prem or S3)
#   - "Destination" bucket (target in GCP)
# Storage Transfer Service or gsutil can be used to Storage Transfer Service or gsutil to copy between them.
# =============================================================================

# -----------------------------------------------------------------------------
# Destination bucket (target of migration)
# -----------------------------------------------------------------------------
# This is where "migrated" data would live in a real project. We use a
# unique name with the configured prefix (bucket names must be globally unique).
# -----------------------------------------------------------------------------
resource "google_storage_bucket" "destination" {
  name     = "${var.bucket_prefix}-migration-dest"
  location = var.region

  # Versioning: keep old versions of objects. Useful for rollback during migration.
  versioning {
    enabled = true
  }

  # Optional: lifecycle rules to move old data to cheaper storage (Nearline/Coldline)
  # after migration. Uncomment to experiment.
  # lifecycle_rule {
  #   condition {
  #     age = 30
  #   }
  #   action {
  #     type          = "SetStorageClass"
  #     storage_class = "NEARLINE"
  #   }
  # }

  uniform_bucket_level_access = true
  force_destroy               = true # Allow Terraform to delete bucket with objects (for learning/demo only)
}

# -----------------------------------------------------------------------------
# Source bucket (simulated "pre-migration" data)
# -----------------------------------------------------------------------------
# In a real migration, the "source" might be S3, an on-prem NFS, or another
# GCS bucket. Here we create a second bucket to run a transfer job
# from this bucket to the destination (same project). For cross-cloud, use
# Storage Transfer Service with AWS credentials or an agent for on-prem.
# -----------------------------------------------------------------------------
resource "google_storage_bucket" "source" {
  name     = "${var.bucket_prefix}-migration-source"
  location = var.region

  versioning {
    enabled = false
  }

  uniform_bucket_level_access = true
  force_destroy               = true
}

# -----------------------------------------------------------------------------
# Optional: Storage Transfer Job (same-project copy)
# -----------------------------------------------------------------------------
# This defines a one-time or scheduled transfer FROM source bucket TO
# destination bucket. In production this is used for this for:
#   - Nightly sync from an on-prem agent or S3
#   - Final incremental copy before cutover
# We create a one-time job that can be run from the console or gcloud.
# -----------------------------------------------------------------------------
resource "google_storage_transfer_job" "source_to_dest" {
  description = "Copy from source bucket to destination (migration simulation)"
  project     = var.project_id

  transfer_spec {
    transfer_options {
      delete_objects_from_source_after_transfer = false
      overwrite_objects_already_existing_in_sink = true
    }

    gcs_data_source {
      bucket_name = google_storage_bucket.source.name
    }

    gcs_data_sink {
      bucket_name = google_storage_bucket.destination.name
    }
  }

  schedule {
    schedule_start_date {
      year  = 2026
      month = 1
      day   = 1
    }
    # Start date in the past = job can run immediately. For recurring, add repeat_interval.
  }

  depends_on = [google_project_service.storage_transfer]
}
