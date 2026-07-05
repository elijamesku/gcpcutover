#####
resource "google_service_account" "storage_transfer" {
  account_id   = "storage-transfer-sa"
  display_name = "Storage Transfer Service Account"
}

resource "google_storage_bucket_iam_member" "transfer_source" {
  bucket = google_storage_bucket.source.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.storage_transfer.email}"
}

resource "google_storage_bucket_iam_member" "transfer_dest" {
  bucket = google_storage_bucket.destination.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.storage_transfer.email}"
}
