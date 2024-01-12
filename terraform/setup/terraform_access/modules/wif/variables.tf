variable "env" {
  type        = string
  description = "The environment type (dev, stage, prod)"
}
variable "project" {
  type        = string
  description = "GCP project id"
}
variable "region" {
  type        = string
  description = "GCP region"
}
variable "repo" {
  type        = string
  description = "GitHub repository path"
}
variable "repo_branch" {
  type        = string
  description = "GitHub repository branch for specified enviroment type"
}
variable "wif_id" {
  type        = string
  description = "Name/id of workload identity federation (WIF) (example, 'gh-oidc-terraform')"
}
variable "wif_sa_roles" {
  type = set(string)
  description = "Roles required for the service account used by GitHub repo"
}
variable "wif_sa_display_name" {
  type = string 
  description = "Brief description of WIF service account's purpose (example, 'GitHub Service Account - infrastructure deployments')"
}