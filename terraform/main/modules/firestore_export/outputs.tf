output "firestore_export_bucket" {
  value       = google_storage_bucket.export_db_bucket.name
  description = "The bucket where firestore exports (backups) are placed"
}