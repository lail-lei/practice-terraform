variable "env" {
  type        = string
  description = "The environment type (dev, stage, prod)"
}
variable "project" {
  type        = string
  description = "GCP project id"
}
variable "region" {
  description = "The GCP region."
  type        = string
}
# App Engine vars
variable "app_engine_location" {
  description = "The location (region) of the app-engine infrastructure (e.g. europe-west)."
  type        = string
}
# Cloud run vars
variable "api_cloud_run_container_image_path" {
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
variable "cf_source_bucket" {
  description = "Name of bucket to store source code for Cloud Functions."
  type        = string
}
variable "db_export_bucket" {
  description = "Name of bucket to store exports from db"
  type        = string
}
variable "db_export_time_zone" {
  description = "The timezone to use for scheduled events."
  type        = string
}
variable "db_export_retention_days" {
  description = "The number of days to keep the datastore export files (recommendation at least 90)"
  type        = string
}
# BigQuery
variable "bq_app_dataset_id" {
  description = "BigQuery dataset id for application data"
  type        = string
}
variable "bq_location" {
  description = "Multi-region location to use for BigQuery"
  type        = string
}
