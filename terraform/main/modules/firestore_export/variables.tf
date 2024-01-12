variable "project" {
  description = "GCP project ID."
  type        = string
}
variable "region" {
  description = "The GCP region, has to match app-engine (e.g. us-central1 for us-central)"
  type        = string
}
variable "cf_source_bucket" {
  description = "Name of bucket to store source code for Cloud Functions."
  type        = string
}
variable "db_export_bucket" {
  description = "Name of bucket to store exports from db"
  type        = string
}
variable "export_retention_days" {
  description = "The number of days to keep the datastore export files (recommendation at least 90)"
  type        = string
}
variable "log_level" {
  description = "Log level for the export cloudfunction."
  type        = string
  default     = "info"
}
variable "time_zone" {
  description = "The timezone to use for scheduled events."
  type        = string
}