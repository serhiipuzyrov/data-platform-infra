output "dbt_docs_cloud_run_service_name" {
  value = google_cloud_run_v2_service.dbt_docs.name
}