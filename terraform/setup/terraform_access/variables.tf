variable "env" {
  type        = string
  description = "The environment type (dev, state, prod)"
}
# define GCP project id
variable "project_id" {
  type        = string
  description = "GCP project id"
}
# define GCP region
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
  description = "GitHub repository branch"
}