output "firestore_export_bucket" {
  value       = google_storage_bucket.firestore_export.name
  description = "The bucket where Firestore exports are stored"
}