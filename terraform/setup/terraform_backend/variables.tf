variable "project_id" {
  type        = string
  description = "The id of the project to which the Google Storage Bucket belongs."
}
variable "region" {
  type        = string
  description = "GCP region for the Google Storage Bucket"
}
variable "bucket" {
  type        = string
  description = "The name (id) of the Google Storage Bucket"
}
variable "storage_class" {
  type        = string
  description = "The storage class of the Storage Bucket"
}