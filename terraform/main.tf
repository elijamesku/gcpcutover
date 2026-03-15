# ******************************************************************************
# Main / Provider
# ******************************************************************************
# Using the Google Cloud provider
# ******************************************************************************

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # GCS bucket for remote state so multiple people can run
  # the same Terraform safely. Uncomment and set bucket name to use.
  # backend "gcs" {
  #   bucket = "terraform-state-bucket-name"
  #   prefix = "gcpcutover"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Required APIs. Enable these once per project.
# Storage Transfer Service and Compute need these.
resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage_transfer" {
  project            = var.project_id
  service            = "storagetransfer.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "sqladmin" {
  project            = var.project_id
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicenetworking" {
  project            = var.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secretmanager" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}
