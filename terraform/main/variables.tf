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
  description = "GCP project region"
}
variable "gcp_storage_class" {
  type        = string
  description = "The storage class of the Storage Bucket to create"
}
variable "slack_webhook" {
  type        = string
  description = "Webhook for sending alerts to slack channel"
}