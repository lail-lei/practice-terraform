variable "project" {
  description = "GCP project ID."
  type        = string
}
variable "region" {
  description = "The GCP region."
  type        = string
}
variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}
variable "container_image_path" {
  description = "The path of the container image to deploy on cloud run."
  type        = string
}
variable "cloud_run_max_scale" {
  description = "The maximum amount of instances the cloud run will scale to"
  type        = number
}
variable "cloud_run_min_scale" {
  description = "Minimum number of api cloud run instances to scale to"
  type        = number
}

