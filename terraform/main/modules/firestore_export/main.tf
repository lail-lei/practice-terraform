# Bucket for export
resource "google_storage_bucket" "firestore_export" {
  project                     = var.project
  name                        = var.export_db_bucket
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

# Service account for running export
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
  name                  = "firestore-export"
  description           = "Initiates an export from firestore (in datastore mode) to a bucket"
  runtime               = "nodejs18"
  timeout               = 30
  max_instances         = 1
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.firestore_export.name
    failure_policy {
      retry = false
    }
  }

  service_account_email = google_service_account.firestore_export.email
  environment_variables = {
    LOG_LEVEL = var.log_level
  }
}

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