# Build Docker image and push to Artifact Registry (You'll need to run this manually or with Cloud Build)
# docker build -t us-central1-docker.pkg.dev/your-gcp-project-id/mern-repo/client ./client
# docker push us-central1-docker.pkg.dev/your-gcp-project-id/mern-repo/client

# Deploy Frontend to Cloud Run
resource "google_cloud_run_service" "mern_client" {
  name     = "mern-client"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${var.project}/mern-repo/client"
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [ google_artifact_registry_repository.mern_repo ]
}

# Deploy Backend to Cloud Run
resource "google_cloud_run_service" "mern_server" {
  name     = "mern-server"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${var.project}/mern-repo/server"
        env {
          name  = "ATLAS_URI"
          value = "mongodb://${google_compute_instance.mongodb.network_interface[0].access_config[0].nat_ip}:27017/mydatabase"
        }
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Output Cloud Run URLs
output "client_url" {
  value = google_cloud_run_service.mern_client.status[0].url
}

output "server_url" {
  value = google_cloud_run_service.mern_server.status[0].url
}
