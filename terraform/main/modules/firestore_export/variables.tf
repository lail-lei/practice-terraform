variable "project_id" {
  description = "GCP project ID."
  type        = string
}
variable "region" {
  description = "The GCP region, has to match app-engine (e.g. us-central1 for us-central)"
  type        = string
}
variable "export_region" {
  description = "The region to use for the export bucket (e.g. multi-region EU)"
  type        = string
}
variable "export_db_bucket" {
  description = "The name to use for the bucket to keep exported files in"
  type        = string
}
variable "export_bucket" {
  description = "The name to use for the bucket to keep exported files in (old - to be removed)"
  type        = string
}
variable "export_retention_days" {
  description = "The number of days to keep the datastore export files (recommendation at least 90)"
  type        = string
}
variable "export_cf_src_bucket" {
  description = "The bucket holding the source code for the export cloud function"
  type        = string
}
variable "export_cf_src_archive" {
  description = "The zip file holding the source code for the export cloud function"
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