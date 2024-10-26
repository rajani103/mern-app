
resource "google_compute_instance" "mongodbinstance" {
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
    # Update package lists and install dependencies
    sudo apt update
    sudo apt install -y gnupg wget

    # Import the public key
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

    # Create a list file for MongoDB
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

    # Reload package database and install MongoDB
    sudo apt update
    sudo apt install -y mongodb-org

    # Start MongoDB service
    sudo systemctl start mongod
    sudo systemctl enable mongod

    # Check MongoDB service status
    sudo systemctl status mongod

    # Optionally, you can add a check and log it
    if sudo systemctl status mongod | grep "running"; then
      echo "MongoDB is running successfully"
    else
      echo "MongoDB failed to start"
      exit 1
    fi
  EOT

}

resource "google_compute_firewall" "mongodb_access_firewall" {
  name    = "mongodb-access"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["mongodb"]
  source_ranges = ["0.0.0.0/0"] # Restrict access further if needed
}

output "mongodb_ip_output" {
  value = google_compute_instance.mongodbinstance.network_interface[0].access_config[0].nat_ip
}