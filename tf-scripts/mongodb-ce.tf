
resource "google_compute_instance" "mongodb" {
  name         = "mongodb-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210908"
      size  = 50  # Customize disk size
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
  tags = ["mongodb"]

  # Install MongoDB on startup
  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update
    sudo apt install -y mongodb
    sudo systemctl start mongodb
    sudo systemctl enable mongodb
  EOT

}

resource "google_compute_firewall" "mongodb_access" {
  name    = "mongodb-access"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["mongodb"]
  source_ranges = ["0.0.0.0/0"] # Restrict access further if needed
}

output "mongodb_ip" {
  value = google_compute_instance.mongodb.network_interface[0].access_config[0].nat_ip
}