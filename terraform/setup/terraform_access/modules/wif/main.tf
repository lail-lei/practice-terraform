# Module for creating creating workload identity pools.
# Google recommends creating a new pool for each non-Google Cloud environment
# that needs to access Google Cloud resources, such as development, staging, or production environments.

# FSO project has 2 GitHub repos that will need to interact with GCP resources
# infra and backend

data "google_project" "project" {}

# Service account used by the repo + environment to interact with GCP
resource "google_service_account" "sa" {
  project = var.project
  account_id   = var.wif_id
  display_name = var.wif_sa_display_name
}

# Provides permissions to administer allow policies on projects
resource "google_project_iam_member" "roles" {
  for_each = var.wif_sa_roles
  project = var.project
  provider = google
  role    = "roles/${each.key}"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

# Identities for GitHub Open Id Connect using above service account
# Allows workflows to deploy to correct GCP project (dev, stage, prod)
resource "google_iam_workload_identity_pool" "pool" {
  provider = google
  workload_identity_pool_id = var.wif_id
  display_name              = "GitHub branch ${var.repo_branch}"
  description               = "Primary OIDC identity pool for GitHub repo ${var.repo} branch ${var.repo_branch}"
  depends_on = [
    google_service_account.sa
  ]
}

# Allows workload using SA to interact with GCP project if the assertion condition is met 
resource "google_iam_workload_identity_pool_provider" "provider" {
  provider = google
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_id
  display_name                       = "GitHub branch ${var.repo_branch}"
  description                        = "Primary OIDC identity pool provider for GitHub repo ${var.repo} branch ${var.repo_branch}"
  attribute_mapping                  = {
    "google.subject" = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.full" = "assertion.repository+assertion.ref"
  }
  # use branch in provider attribute condition to enforce separate pool per environment
  attribute_condition = "'${var.repo}refs/heads/${var.repo_branch}' == attribute.full"
  oidc {
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}

# Updates the IAM policy to grant "iam.workloadIdentityUser" role to the service account. 
# Preserves any other roles previously granted to the service account
resource "google_service_account_iam_binding" "sa-account-iam" {
  provider = google
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [ 
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.full/${var.repo}refs/heads/${var.repo_branch}" 
  ]
  depends_on = [
    google_service_account.sa,
    google_iam_workload_identity_pool.pool
  ]
}