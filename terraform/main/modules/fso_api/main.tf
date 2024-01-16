locals {
  roles = [
    "datastore.user",
    "secretmanager.secretAccessor",
    "logging.logWriter"
  ]
}

# Create an Artifact Registry repo to store API Docker images.
# Cicd workflows upload Docker images to this repo
resource "google_artifact_registry_repository" "api-artifact-repo" {
  location      = var.region
  repository_id = var.service_name
  description   = "Docker repo for API"
  format        = "DOCKER" 
}

# Create service account for FSO api to use to interact with datastore/logging
resource "google_service_account" "fso_api" {
  provider = google
  account_id   = var.service_name
  display_name = var.service_name
  description  = "fso service account for API"
}
# Add permissions to above service account
resource "google_project_iam_member" "fso_api" {
  provider = google
  for_each = toset(local.roles)
  project = var.project
  role    = "roles/${each.key}"
  member  = "serviceAccount:${google_service_account.fso_api.email}"
}

# Create Cloud Run service
resource "google_cloud_run_service" "fso_api" {
  provider   = google-beta
  depends_on = [google_project_iam_member.fso_api]

  name                       = var.service_name
  location                   = var.region
  autogenerate_revision_name = true

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = var.cloud_run_max_scale
        "autoscaling.knative.dev/minScale"        = var.cloud_run_min_scale
      }
    }
    spec {
      service_account_name = google_service_account.fso_api.email
      containers {
        image = var.container_image_path
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
