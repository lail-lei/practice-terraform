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

# App engine required for Firestore and Cloud Scheduler
resource "google_app_engine_application" "required_app_engine" {
  project       = var.project
  location_id   = var.app_engine_location
  # enables a Datastore-compatible database
  database_type = "CLOUD_DATASTORE_COMPATIBILITY"
}

# Create Cloud Run API + service account
# Create Artifact Registry Repo (API Docker Images are stored in Artifact Registry)
module "fso_api" {
  source = "./modules/fso_api"
  service_name                           = "fso-api"
  container_image_path                   = var.api_cloud_run_container_image_path
  project                                = var.project
  region                                 = var.region
  cloud_run_max_scale                    = var.api_cloud_run_max_scale
  cloud_run_min_scale                    = var.api_cloud_run_min_scale
}

# Create Firestore db export Cloud Function. This CF 1, invokes Firestore export jobs and stores
# exported files in a storage bucket, and 2: writes application data to BiqQuery tables for analytics purposes.
# Creates storage bucket to store Cloud Function source code
# Creates storage bucket to store db exports (backups) 
# Creates Cloud Scheduler job and Pub/Sub topic to trigger Cloud Function
module "firestore_export" {
  source = "./modules/firestore_export"
  project               = var.project
  region                = var.region
  time_zone             = var.db_export_time_zone
  export_retention_days = var.db_export_retention_days
  db_export_bucket      = var.db_export_bucket
  cf_source_bucket      = var.cf_source_bucket
}

# Creates BigQuery application data dataset 
module "bigquery" {
  source = "./modules/bigquery"
  app_dataset_id = var.bq_app_dataset_id
  location = var.bq_location
}