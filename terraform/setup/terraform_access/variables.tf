variable "env" {
  type        = string
  description = "The environment type (dev, state, prod)"
}
# define GCP region
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "us-east4"
}
# define GCP project name
variable "gcp_project" {
  type        = string
  description = "GCP project name"
}
variable "gh_repo" {
  type        = string
  description = "GH repository path"
}
variable "gh_repo_branch" {
  type        = string
  description = "GH repository branch"
  default = "dev"
}variable "env" {
  type        = string
  description = "The environment type (dev, state, prod)"
}
# define GCP region
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "us-east4"
}
# define GCP project name
variable "gcp_project" {
  type        = string
  description = "GCP project name"
}
variable "gh_repo" {
  type        = string
  description = "GH repository path"
}
variable "gh_repo_branch" {
  type        = string
  description = "GH repository branch"
  default = "dev"
}