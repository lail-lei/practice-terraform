variable "env" {
  type        = string
  description = "The environment type (dev, stage, prod)"
}
variable "project_id" {
  type        = string
  description = "GCP project id"
}
# App Engine vars
variable "app_engine_location" {
  description = "The location (region) of the app-engine infrastructure (e.g. europe-west)."
  type        = string
}
# Cloud run vars
variable "container_image_path" {
  description = "The path of the container image to deploy on cloud run."
  type        = string
}
variable "api_cloud_run_max_scale" {
  description = "The maximum amount of instances the cloud run will scale to"
  type        = number
}
variable "api_cloud_run_min_scale" {
  description = "Minimum number of api cloud run instances to scale to"
  type        = number
}
# Firestore export vars
variable "region" {
  description = "The GCP region."
  type        = string
}
variable "time_zone" {
  description = "The timezone to use for scheduled events."
  type        = string
}
variable "export_db_bucket" {
  description = "The name to use for the bucket to keep exported files in"
  type        = string
}
variable "export_retention_days" {
  description = "The number of days to keep the datastore export files (recommendation at least 90)"
  type        = string
}

variable "slack_webhook" {
  type        = string
  description = "Webhook for sending alerts to slack channel"
}
