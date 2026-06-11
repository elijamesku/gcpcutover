# ******************************************************************************
# COMPUTE ENGINE - Lift-and-Shift Target
# ******************************************************************************

resource "google_compute_instance" "migration_vm" {
  count        = var.enable_compute ? 1 : 0
  name         = "migration-demo-vm"
  machine_type = "e2-micro" # Free tier eligible in many regions
  zone         = "${var.region}-a"
  tags         = ["migration-vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.compute_subnet.id
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Migration demo VM - GCP networking and storage are ready" > /tmp/ready.txt
    apt-get update && apt-get install -y gsutil || true
  EOT

  allow_stopping_for_update = true
}
