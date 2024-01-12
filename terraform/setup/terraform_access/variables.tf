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
variable "repo_infra" {
  type        = string
  description = "Path to infrastructure GitHub repository"
}
variable "repo_branch_infra" {
  type        = string
  description = "Branch used by infrastructure GitHub repository for enivronment specified in var.env"
}
variable "repo_api" {
  type        = string
  description = "Path to api GitHub repository"
}
variable "repo_branch_api" {
  type        = string
  description = "Branch used by backend code GitHub repository for enivronment specified in var.env"
}