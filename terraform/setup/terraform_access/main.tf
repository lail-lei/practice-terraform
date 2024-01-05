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
    prefix = "terraform-access"
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

data "google_project" "project" {}

# Creates a resource for each service in set
# The created resource's name is the key value in set 
# -> example: "google_project_service" "service"
resource "google_project_service" "cloudbuild.googleapis.com" {
  for_each = toset( ["iam.googleapis.com", "cloudresourcemanager.googleapis.com", "iamcredentials.googleapis.com", "sts.googleapis.com", "serviceusage.googleapis.com", "secretmanager.googleapis.com", "cloudfunctions.googleapis.com", "cloudbuild.googleapis.com"] )
  project = var.gcp_project
  service = each.key
}

# GitHub OIDC

resource "google_service_account" "gh-oidc-sa" {
  project = var.gcp_project
  account_id   = "gh-oidc-terraform"
  display_name = "GiHub Service Account"
}

# Identities for GitHub Open Id Connect using above service account
# Allows workflows to deploy to correct project (dev, stage, prod)
resource "google_iam_workload_identity_pool" "pool" {
  provider = google
  workload_identity_pool_id = "gh-oidc-terraform"
  display_name              = "Github branch ${var.gh_repo_branch}"
  description               = "Primary OIDC identity pool for GitHub repo ${var.gh_repo} branch ${var.gh_repo_branch}"
  depends_on = [
    google_service_account.sa
  ]
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  provider = google
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "gh-oidc-terraform"
  display_name                       = "Github branch ${var.gh_repo_branch}"
  description                        = "Primary OIDC identity pool provider for GitHub repo ${var.gh_repo} branch ${var.gh_repo_branch}"
  attribute_mapping                  = {
    "google.subject" = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.full" = "assertion.repository+assertion.ref"
  }
  attribute_condition = "'${var.gh_repo}refs/heads/${var.gh_repo_branch}' == attribute.full"
  oidc {
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}

# Updates the IAM policy to grant "iam.workloadIdentityUser" role.
# to the gh-oidc-sa service account. Preserves any other 
# roles previously granted to the gh-oidc-sa service account
resource "google_service_account_iam_binding" "sa-account-iam" {
  provider = google
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [ 
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.full/${var.gh_repo}refs/heads/${var.gh_repo_branch}" 
  ]
  depends_on = [
    google_service_account.sa,
    google_iam_workload_identity_pool.pool
  ]
}

# Provides permissions to administer allow policies on projects.
resource "google_project_iam_member" "roles" {
  for_each = toset( ["resourcemanager.projectIamAdmin", "iam.serviceAccountAdmin", "iam.serviceAccountUser", "iam.workloadIdentityPoolAdmin", "secretmanager.admin", "secretmanager.secretAccessor", "secretmanager.secretVersionManager", "serviceusage.serviceUsageAdmin", "storage.admin", "storage.objectAdmin", "cloudfunctions.admin", "cloudfunctions.developer", "cloudscheduler.admin", "cloudscheduler.jobRunner"] )
  project = var.gcp_project
  provider = google
  role    = "roles/${each.key}"
  member  = "serviceAccount:${google_service_account.sa.email}"
}