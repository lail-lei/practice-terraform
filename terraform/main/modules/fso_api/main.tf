locals {
  roles = [
    "roles/datastore.user",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter"
  ]
}

# Service account
resource "google_service_account" "fso_api" {
  provider = google
  account_id   = var.name
  display_name = var.name
  description  = "fso service account for API"
}

resource "google_project_iam_member" "fso_api" {
  count   = length(local.roles)
  project = var.project
  role    = local.roles[count.index]
  member  = "serviceAccount:${google_service_account.fso_api.email}"
}

# Cloud run
resource "google_cloud_run_service" "fso_api" {
  provider   = google-beta
  depends_on = [google_project_iam_member.fso_api]

  name                       = var.name
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
