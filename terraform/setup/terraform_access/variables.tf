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
  description = "GitHub repository branch"
}