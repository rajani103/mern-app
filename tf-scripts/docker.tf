resource "docker_registry_image" "client_image_registry" {
  name          = docker_image.client_image.name
  keep_remotely = true
}

resource "docker_image" "client_image" {
  name          = "us-central1-docker.pkg.dev/${var.project}/mern-repo/client:latest"
  build {
    context    = "../client"
    dockerfile = "Dockerfile"
    build_arg = {
      REACT_APP_YOUR_HOSTNAME: google_cloud_run_service.mern_server_app.status[0].url
    }
  }
}

resource "docker_registry_image" "server_image_registry" {
  name          = docker_image.server_image.name
  keep_remotely = true
}

resource "docker_image" "server_image" {
  name          = "us-central1-docker.pkg.dev/${var.project}/mern-repo/server:latest"
  build {
    context    = "../server"
    dockerfile = "Dockerfile"  # Ensure the image gets pushed to Artifact Registry
  }
}