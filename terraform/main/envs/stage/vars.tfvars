# Environment
env = "stage"

# GCP project id
project = "terraform-practice-stage"

# GCP project region
region = "europe-west1"

# App Engine vars
app_engine_location = "europe-west"

# Cloud run vars
api_cloud_run_container_image_path = "us-docker.pkg.dev/cloudrun/container/hello"
api_cloud_run_max_scale = 3
api_cloud_run_min_scale = 0

# Firestore export vars
db_export_time_zone = "Europe/Paris"
db_export_retention_days = 90
db_export_bucket= "terraform-practice-stage-db-export"
cf_source_bucket= "terraform-practice-stage-cloudfunctions-source"

# BigQuery vars
bq_app_dataset_id = "firestore_app_data"
bq_location = "EU"
