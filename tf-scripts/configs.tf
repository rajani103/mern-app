provider "google" {
  project = "second-core-431718-j2"
  region  = "us-central1"
}
variable "project"{
    default = "second-core-431718-j2"
}
terraform {
  backend "gcs" {
    bucket = " terraform-state-backend12891y4o28r3hewi8892"
    prefix     = "terraform/state"              
  }
}