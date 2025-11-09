resource "google_service_account" "dbt_runner" {
  account_id   = "dbt-runner"
  display_name = "dbt runner service account"
}

resource "google_project_iam_member" "dbt_bq_writer" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dbt_runner.email}"
}