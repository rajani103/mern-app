provider "google" {
  project = "heroviredacademics"
  region  = "us-central1"
}
variable "project"{
    default = "heroviredacademics"
}
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
  backend "gcs" {
    bucket = "terraform-state-bucket293ehiuwei"
    prefix     = "terraform/state"              
  }
}
provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address     = "us-central1-docker.pkg.dev"
  }
}