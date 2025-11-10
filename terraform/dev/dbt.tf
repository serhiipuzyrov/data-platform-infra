#########################################
# DBT Runner Service Account
#########################################

resource "google_service_account" "dbt_runner" {
  account_id   = "dbt-runner"
  display_name = "DBT Runner Service Account"
  description  = "Service Account for running DBT jobs"
}

# Grant BQ permissions
resource "google_project_iam_member" "dbt_bq_writer" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dbt_runner.email}"
}

# Optional: grant read access to GCS (for seeds or external tables)
resource "google_project_iam_member" "dbt_gcs_reader" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.dbt_runner.email}"
}

#########################################
# Artifact Registry (DBT image repo)
#########################################

resource "google_artifact_registry_repository" "dbt" {
  location      = var.region
  repository_id = "data-platform-dbt"
  format        = "DOCKER"
}

#########################################
# Cloud Run Job for DBT
#########################################

# resource "google_cloud_run_v2_job" "dbt_job" {
#   name     = "dbt-run"
#   location = var.region
#
#   template {
#     template {
#       service_account = google_service_account.dbt_runner.email
#
#       containers {
#         image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.dbt.repository_id}/dbt:latest"
#         # Example: run dbt commands automatically
#         command = ["dbt"]
#         args    = ["run", "--project-dir", "/dbt_project"]
#         # Environment variables for dbt (customize as needed)
#         env {
#           name  = "DBT_PROFILES_DIR"
#           value = "/.dbt"
#         }
#         resources {
#           limits = {
#             cpu    = "1"
#             memory = "2Gi"
#           }
#         }
#       }
#       max_retries = 1
#       timeout     = "3600s"
#     }
#   }
#   # IAM Binding: allow Scheduler to trigger job
#   depends_on = [
#     google_service_account.dbt_runner,
#     google_artifact_registry_repository.dbt
#   ]
# }
#
# #########################################
# # IAM Binding — allow Scheduler to run Cloud Run Job
# #########################################
#
# resource "google_project_iam_member" "scheduler_runner" {
#   project = var.project_id
#   role    = "roles/run.invoker"
#   member  = "serviceAccount:${google_service_account.dbt_runner.email}"
# }
#
# # #########################################
# # # Cloud Scheduler to trigger DBT job
# # #########################################
# #
# # resource "google_cloud_scheduler_job" "dbt_scheduler" {
# #   name        = "dbt-scheduler"
# #   description = "Trigger DBT Cloud Run Job periodically"
# #   schedule    = "0 2 * * *" # every day at 02:00
# #   region = var.region
# #   http_target {
# #     uri = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.dbt_job.name}:run"
# #     http_method = "POST"
# #     oauth_token {
# #       service_account_email = google_service_account.dbt_runner.email
# #     }
# #   }
# #   depends_on = [
# #     google_cloud_run_v2_job.dbt_job
# #   ]
# # }
