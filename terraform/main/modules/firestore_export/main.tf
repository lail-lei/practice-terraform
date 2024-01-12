# Create service account for handling exports from Firestore db
resource "google_service_account" "firestore_export" {
  account_id   = "firestore-export"
  display_name = "Firestore Export"
}
# Add permissions to above service account
resource "google_project_iam_member" "roles" {
  for_each = toset( [ 
                      "datastore.importExportAdmin", # for exporting db backups
                      "bigquery.jobUser", # for creating BQ dataset
                      "bigquery.dataEditor", # for creating BQ tables and writing data to tables
                    ] )
  project = var.project
  provider = google
  role    = "roles/${each.key}"
  member  = "serviceAccount:${google_service_account.firestore_export.email}"
}

# Create storage bucket that will hold db exports
resource "google_storage_bucket" "firestore_export" {
  project                     = var.project
  name                        = var.db_export_bucket
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = var.export_retention_days
    }
    action {
      type = "Delete"
    }
  }
}
# Add permissions to storage bucket
resource "google_storage_bucket_iam_member" "firestore_export" {
  bucket = google_storage_bucket.firestore_export.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.firestore_export.email}"
}

# Compress Cloud Function (cf) source code 
locals {
  cf_root_dir = "${path.module}/../../../../cloudfunctions/db_export"
  timestamp   = formatdate("YYMMDDhhmmss", timestamp())
}
data "archive_file" "source" {
  type        = "zip"
  source_dir  = local.cf_root_dir
  output_path = "/tmp/function-${local.timestamp}.zip"
}

# Create bucket that will host the cf source code
resource "google_storage_bucket" "cf-source-bucket" {
  project                     = var.project
  name                        = var.cf_source_bucket
  location                    = var.region
  storage_class               = "STANDARD"
  versioning {
    enabled = true
  }
}
# Add source code zip file to cf source code bucket
resource "google_storage_bucket_object" "cf-object" {
  name   = "source.zip#${data.archive_file.source.output_md5}"
  bucket = google_storage_bucket.cf-source-bucket.name
  source = data.archive_file.source.output_path
}

# Create the cloud function
resource "google_cloudfunctions_function" "export_function" {
  name                  = "firestoreExport"
  description           = "Initiates an export from Firestore (in Datastore mode) to a bucket. Also writes Firestore data to BigQuery dataset"
  runtime               = "nodejs18"
  source_archive_bucket = google_storage_bucket.cf-source-bucket.name
  source_archive_object = google_storage_bucket_object.cf-object.name
  timeout               = 30
  max_instances         = 1

  environment_variables = {
    STORAGE_BUCKET = "gs://${google_storage_bucket.firestore_export.name}"
    GCLOUD_PROJECT = var.project
    LOG_LEVEL = var.log_level
  }

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.firestore_export.name
    failure_policy {
      retry = false
    }
  }

  service_account_email = google_service_account.firestore_export.email
}

# Create pub/sub topic to send via scheduler job
resource "google_pubsub_topic" "firestore_export" {
  name = "firestore-export"
}

# Create scheduler to trigger db export function
resource "google_cloud_scheduler_job" "export_job" {
  project     = var.project
  region      = var.region
  name        = "Firestore-export-job"
  description = "Daily export of entire Firestore database"
  schedule    = "0 4 * * *"
  time_zone   = var.time_zone

  pubsub_target {
    topic_name = google_pubsub_topic.firestore_export.id
  }
}