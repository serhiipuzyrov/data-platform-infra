#########################################
# Artifact Registry (DBT image repo)
#########################################

resource "google_artifact_registry_repository" "dbt" {
  location      = var.region
  repository_id = "data-platform-dbt"
  format        = "DOCKER"
  cleanup_policies {
    id = "keep-latest-3"
    action = "KEEP"
    most_recent_versions {keep_count = 3}
  }
    cleanup_policies {
    id = "delete"
    action = "DELETE"
    condition {older_than = "1s"}
  }
}

########################################
# Cloud Run Job for DBT
########################################

resource "google_cloud_run_v2_job" "dbt_job" {
  name     = "dbt-run"
  location = var.region
  deletion_protection=false
  template {
    template {
      service_account = var.dbt_runner_email
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.dbt.repository_id}/dbt-image:latest"
        env {
          name  = "DBT_PROFILES_DIR"
          value = "/.dbt"
        }
        env {
          name  = "DBT_TARGET"
          value = var.env
        }
        resources {
          limits = {
            cpu    = "1"
            memory = "2Gi"
          }
        }
      }
      max_retries = 0
      timeout     = "3600s"
    }
  }
  # IAM Binding: allow Scheduler to trigger job
  depends_on = [
    google_artifact_registry_repository.dbt
  ]
}

#########################################
# Cloud Scheduler to trigger DBT job
#########################################

resource "google_cloud_scheduler_job" "dbt_scheduler" {
  name        = "dbt-scheduler"
  description = "Trigger DBT Cloud Run Job periodically"
  schedule    = "0 2 * * *" # every day at 02:00
  region = var.region
  http_target {
    uri = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.dbt_job.name}:run"
    http_method = "POST"
    oauth_token {
      service_account_email = var.dbt_runner_email
    }
  }
  depends_on = [
    google_cloud_run_v2_job.dbt_job
  ]
}

#########################################
# DBT Docs Hosting on Cloud Run
#########################################

resource "google_cloud_run_v2_service" "dbt_docs" {
  name     = "dbt-docs"
  project  = var.project_id
  location = var.region
  provider = google-beta
  launch_stage = "BETA"
  ingress      = "INGRESS_TRAFFIC_ALL"
  iap_enabled  = true
  invoker_iam_disabled = true
  scaling {
    max_instance_count = 8
  }
  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.dbt.repository_id}/dbt-docs-image:latest"
    }
  }
}


