# Environment
env = "dev"

# GCP project id
project = "fresh-start-410522"

# GCP project region
region = "europe-west1"

# App Engine vars
app_engine_location = "europe-west"

# Cloud run vars
api_cloud_run_container_image_path = "europe-west1-docker.pkg.dev/fresh-start-410522/fso-api/fso-api"
api_cloud_run_max_scale = 3
api_cloud_run_min_scale = 0

# Firestore export vars
db_export_time_zone = "Europe/Paris"
db_export_retention_days = 90
db_export_bucket= "fresh-start-410522-db-export"
cf_source_bucket= "fresh-start-410522-cloudfunctions-source"

# BigQuery vars
bq_app_dataset_id = "firestore_app_data"
bq_location = "EU"
