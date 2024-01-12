# assumption is that we'll want to add more bigquery infrastructure as project grows
# so created a module instead of adding this directly in main
resource "google_bigquery_dataset" "app_dataset" {
  dataset_id = var.app_dataset_id
  description = "Application data (orders, user contact info). Used by Analytics to track sofa purchases by FSO users" 
  location   = var.location
}

