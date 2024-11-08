provider "google" {
  project = "heroviredacademics"
  region  = "us-central1"
}
variable "project"{
    default = "heroviredacademics"
}
terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket293ehiuwei"
    prefix     = "terraform/state"              
  }
}