output "dbt_runner_email" {
  value = google_service_account.dbt_runner.email
}