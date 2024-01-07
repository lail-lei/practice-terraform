output "fso_api_url" {
  value       = google_cloud_run_service.fso_api.status[0].url
  description = "The native cloud run URL to the API"
}