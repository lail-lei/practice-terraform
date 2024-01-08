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
  backend "gcs" {
    prefix = "main"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}

locals {
  max_cf_instances        = 1
  fso_api_name          = "fso-api"
}

# App engine required for firestore and cloud scheduler
resource "google_app_engine_application" "required_app_engine" {
  project       = var.project
  location_id   = var.app_engine_location
  # enables a Datastore-compatible database
  database_type = "CLOUD_DATASTORE_COMPATIBILITY"
}

module "firestore_export" {
  source = "./modules/firestore_export"

  project               = var.project
  region                = var.region
  time_zone             = var.time_zone
  export_db_bucket      = var.export_db_bucket
  export_retention_days = var.export_retention_days
}

module "fso_api" {
  source = "./modules/fso_api"
  name                                   = local.fso_api_name
  container_image_path                   = var.container_image_path
  project                                = var.project
  region                                 = var.region
  cloud_run_max_scale                    = var.api_cloud_run_max_scale
  cloud_run_min_scale                    = var.api_cloud_run_min_scale
}
