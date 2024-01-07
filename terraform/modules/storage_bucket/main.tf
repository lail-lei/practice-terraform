# Creates a Google Cloud Storage Bucket 
resource "google_storage_bucket" "default" {
  project       = var.project
  name          = var.bucket
  location      = var.region
  storage_class = var.storage_class
  versioning {
    enabled = true
  }
}