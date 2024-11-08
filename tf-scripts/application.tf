# Build Docker image and push to Artifact Registry (You'll need to run this manually or with Cloud Build)
# docker build -t us-central1-docker.pkg.dev/your-gcp-project-id/mern-repo/client ./client
# docker push us-central1-docker.pkg.dev/your-gcp-project-id/mern-repo/client

# Deploy Frontend to Cloud Run
resource "google_cloud_run_service" "mern_client_app" {
  name     = "mern-client"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${var.project}/mern-repo/client:latest"
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        env {
        name = "REACT_APP_YOUR_HOSTNAME"
        value = google_cloud_run_service.mern_server_app.status[0].url
      }
      }
      
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Deploy Backend to Cloud Run
resource "google_cloud_run_service" "mern_server_app" {
  name     = "mern-server"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${var.project}/mern-repo/server:latest"
        env {
          name  = "ATLAS_URI"
          value = "mongodb+srv://rajnee:rajani103@cluster0.py2ov.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
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
resource "google_cloud_run_service_iam_member" "backend_iam_public" {
  service    = google_cloud_run_service.mern_server_app.name
  location   = google_cloud_run_service.mern_server_app.location
  role       = "roles/run.invoker"
  member     = "allUsers"
}
resource "google_cloud_run_service_iam_member" "frontend_iam_public" {
  service    = google_cloud_run_service.mern_client_app.name
  location   = google_cloud_run_service.mern_client_app.location
  role       = "roles/run.invoker"
  member     = "allUsers"
}
# Output Cloud Run URLs
output "client_url" {
  value = google_cloud_run_service.mern_client_app.status[0].url
}

output "server_url" {
  value = google_cloud_run_service.mern_server_app.status[0].url
}