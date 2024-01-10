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

# App engine required for firestore and cloud scheduler
resource "google_app_engine_application" "required_app_engine" {
  project       = var.project
  location_id   = var.app_engine_location
  # enables a Datastore-compatible database
  database_type = "CLOUD_DATASTORE_COMPATIBILITY"
}

module "fso_api" {
  source = "./modules/fso_api"
  service_name                           = "fso-api"
  container_image_path                   = var.api_cloud_run_container_image_path
  project                                = var.project
  region                                 = var.region
  cloud_run_max_scale                    = var.api_cloud_run_max_scale
  cloud_run_min_scale                    = var.api_cloud_run_min_scale
}

module "bigquery" {
  source = "./modules/bigquery"
  app_dataset_id = var.bq_app_dataset_id
  location = var.bq_location
}

# Create cloud function
module "firestore_export" {
  source = "./modules/firestore_export"
  project               = var.project
  region                = var.region
  time_zone             = var.db_export_time_zone
  export_retention_days = var.db_export_retention_days
  db_export_bucket      = var.db_export_bucket
  cf_source_bucket      = var.cf_source_bucket
}