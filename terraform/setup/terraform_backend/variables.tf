# GCP project name
variable "project" {
  type        = string
  description = "GCP project name"
}
# GCP region
variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-east4"
}
# Name of bucket to use for terraform backend states
variable "bucket" {
  type        = string
  description = "The name of the Google Storage Bucket to create"
}
variable "storage_class" {
  type        = string
  description = "The storage class of the Storage Bucket to create"
  default     = "REGIONAL"
}