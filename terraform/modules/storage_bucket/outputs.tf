output "bucket" {
  description = "Name (id) of the bucket"
  value       = google_storage_bucket.tf-bucket.name
}