#########################################
# DBT Runner Service Account
#########################################

resource "google_service_account" "dbt_runner" {
  account_id   = "dbt-runner"
  display_name = "DBT Runner Service Account"
  description  = "Service Account for running DBT jobs in ${var.env} environment"
}

locals {
  dbt_sa_roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectViewer",
  ]
}

resource "google_project_iam_member" "dbt_sa_roles" {
  for_each = toset(local.dbt_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.dbt_runner.email}"
}

#########################################
# Artifact Registry (DBT image repo)
#########################################

resource "google_artifact_registry_repository" "dbt" {
  location      = var.region
  repository_id = "data-platform-dbt"
  format        = "DOCKER"
}
