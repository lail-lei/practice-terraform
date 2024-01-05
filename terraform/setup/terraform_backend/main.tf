terraform {
  required_providers {
    google = {
      version = ">= 4.47.0"
    }
    google-beta = {
        version = "~> 4.47.0"
    }
  }
  required_version = ">=0.14.9"
  # Remove following block if setting up terraform for new env
  backend "gcs" {
    prefix = "backend"
  }
  # End block
}

provider "google" {
  project = var.project
  region  = var.region
}

# Used to create original GCS Bucket to store terraform states
resource "google_storage_bucket" "tf-bucket" {
  project       = var.project
  name          = var.bucket
  location      = var.region
  storage_class = var.storage_class
  versioning {
    enabled = true
  }
}