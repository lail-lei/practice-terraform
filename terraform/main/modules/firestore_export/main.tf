# Compress cloud function source code
locals {
  cf_root_dir = "${path.module}/../../../../cloudfunctions/db_export"
  timestamp   = formatdate("YYMMDDhhmmss", timestamp())
}
data "archive_file" "source" {
  type        = "zip"
  source_dir  = local.cf_root_dir
  output_path = "/tmp/function-${local.timestamp}.zip"
}

# Bucket for export
resource "google_storage_bucket" "export_db_bucket" {
  project                     = var.project
  name                        = "${var.project}-db-export"
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.export_retention_days
    }
    action {
      type = "Delete"
    }
  }
}

# Create bucket that will host the source code
resource "google_storage_bucket" "cf-source-bucket" {
  name                        = "${var.project}-cloudfunctions-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

# Add source code zip to bucket
resource "google_storage_bucket_object" "cf-object" {
  name   = "source.zip#${data.archive_file.source.output_md5}"
  bucket = google_storage_bucket.cf-source-bucket.name
  source = data.archive_file.source.output_path
}

# Service account for running export and iam roles
resource "google_service_account" "firestore_export" {
  account_id   = "firestore-export"
  display_name = "Firestore Export"
}
resource "google_project_iam_member" "firestore_export" {
  project = var.project
  member  = "serviceAccount:${google_service_account.firestore_export.email}"
  role    = "roles/datastore.importExportAdmin"
}
resource "google_storage_bucket_iam_member" "firestore_export" {
  bucket = google_storage_bucket.export_db_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.firestore_export.email}"
}

# Create the cloud function
resource "google_cloudfunctions_function" "export_function" {
  name                  = "firestoreExport"
  description           = "Initiates an export from firestore (in datastore mode) to a bucket"
  runtime               = "nodejs18"
  timeout               = 30
  max_instances         = 1
  source_archive_bucket = google_storage_bucket.cf-source-bucket.name
  source_archive_object = google_storage_bucket_object.cf-object.name

  environment_variables = {
    STORAGE_BUCKET = "gs://${google_storage_bucket.export_db_bucket.name}"
    GCP_PROJECT = var.project
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

# Create pub/sub opic to send via scheduler job
resource "google_pubsub_topic" "firestore_export" {
  name = "firestore-export"
}

# Create scheduler
resource "google_cloud_scheduler_job" "export_job" {
  project     = var.project
  region      = var.region
  name        = "Firestore-export-job"
  description = "Daily export of entire firestore database"
  schedule    = "0 4 * * *"
  time_zone   = var.time_zone

  pubsub_target {
    topic_name = google_pubsub_topic.firestore_export.id
    data       = base64encode("{\"bucket\": \"gs://${google_storage_bucket.export_db_bucket.name}\"}")
  }
}