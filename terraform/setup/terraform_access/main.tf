locals {
    # APIs that need to be enabled in GCP project
    required_apis = [
                      "appengine.googleapis.com", 
                      "artifactregistry.googleapis.com", 
                      "bigquery.googleapis.com",
                      "cloudbuild.googleapis.com", 
                      "cloudfunctions.googleapis.com",
                      "cloudresourcemanager.googleapis.com", 
                      "firestore.googleapis.com",           
                      "iam.googleapis.com", 
                      "iamcredentials.googleapis.com", 
                      "logging.googleapis.com",
                      "monitoring.googleapis.com",
                      "pubsub.googleapis.com", 
                      "run.googleapis.com",
                      "secretmanager.googleapis.com", 
                      "serviceusage.googleapis.com", 
                      "sts.googleapis.com" 
                    ]

    # Roles required by infrastructure repo sa to create/update resources in GCP project
    wif_sa_roles_infra = [
                          "appengine.appCreator",
                          "artifactregistry.admin",
                          "appengine.serviceAdmin", 
                          "bigquery.dataEditor",
                          "cloudfunctions.developer",
                          "cloudscheduler.admin",
                          "iam.serviceAccountAdmin", 
                          "iam.serviceAccountUser", 
                          "pubsub.editor",
                          "resourcemanager.projectIamAdmin",
                          "run.developer",
                          "secretmanager.admin", 
                          "secretmanager.secretAccessor", 
                          "secretmanager.secretVersionManager", 
                          "serviceusage.serviceUsageAdmin", 
                          "storage.admin", 
                          "storage.objectAdmin" 
                        ]

    # Roles required by api repo sa to upload image to docker registry
    # and deploy the cloud run revision
    wif_sa_roles_api_cicd = [ 
                                "artifactregistry.writer", 
                                "run.developer", 
                                "iam.serviceAccountUser"
                            ]
}

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
  project = var.project
  region  = var.region
}

# Enables apis in GCP project
resource "google_project_service" "service" {
  for_each = toset(local.required_apis)
  project = var.project
  service = each.key
}

# GitHub OIDC
# If we need to create separate providers
# for each repo, google recommends creating two pools
# 1 pool per provider: https://cloud.google.com/iam/docs/best-practices-for-using-workload-identity-federation#avoid-subject-collisions

# Create WIF pool for deploying infrastructure (from infra GitHub repo)
module wif_infra {
  source = "./modules/wif"
  wif_id = "gh-oidc-infra-2"
  wif_sa_display_name = "GitHub Service Account - infrastructure deployments"
  env = var.env
  project = var.project
  region = var.region
  repo = var.repo_infra
  repo_branch = var.repo_branch_infra
  wif_sa_roles= toset(local.wif_sa_roles_infra)
}

# Create WIF pool for deploying api to artificat registry (from backend code GitHub repo)
module wif_api_cicd {
  source = "./modules/wif"
  wif_id = "gh-oidc-api-cicd-2"
  wif_sa_display_name = "GitHub Service Account - api deployments"
  env = var.env
  project = var.project
  region = var.region
  repo = var.repo_api
  repo_branch = var.repo_branch_api
  wif_sa_roles= toset(local.wif_sa_roles_api_cicd)
}
