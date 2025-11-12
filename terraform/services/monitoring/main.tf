#########################################
# DBT jobs monitoring and alerting
#########################################

# Email notification channel
resource "google_monitoring_notification_channel" "email_channel" {
  display_name = "DBT Job Failure Alert"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

# Log-based metric for DBT errors
resource "google_logging_metric" "dbt_errors" {
  name   = "dbt_error_count"
  filter = <<-EOT
    resource.type="cloud_run_job"
    resource.labels.job_name="dbt-run"
    (
      textPayload=~"ERROR" OR
      textPayload=~"Completed with .* error" OR
      textPayload=~"Database Error" OR
      textPayload=~"Compilation Error" OR
      textPayload=~"Failure in model" OR
      jsonPayload.message=~"ERROR"
    )
  EOT

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "DBT Error Count"
  }
}

# Alert #1: DBT errors in logs (catches dbt build errors)
resource "google_monitoring_alert_policy" "dbt_log_errors" {
  display_name = "DBT Errors Detected in Logs"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "DBT error found in logs"

    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/dbt_error_count\" AND resource.type=\"cloud_run_job\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_channel.name]

  documentation {
    content = <<-EOT
      DBT errors detected in Cloud Run job logs.

      Check the logs:
      https://console.cloud.google.com/run/jobs/details/${var.region}/dbt-run/executions?project=${var.project_id}

      This alert triggers on:
      - Database errors
      - Compilation errors
      - Model execution failures
      - Any line containing "ERROR" or "Failure in model"
    EOT
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s"
  }

  depends_on = [
    google_logging_metric.dbt_errors
  ]
}

# Alert #2: Complete job failure (container crash, timeout, etc.)
resource "google_monitoring_alert_policy" "dbt_job_failure" {
  display_name = "DBT Cloud Run Job Execution Failed"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "DBT job execution failed"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_job\" AND resource.labels.job_name=\"dbt-run\" AND metric.type=\"run.googleapis.com/job/completed_execution_count\" AND metric.labels.result=\"failed\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_channel.name]

  documentation {
    content = <<-EOT
      DBT Cloud Run job execution failed completely.

      Check the logs:
      https://console.cloud.google.com/run/jobs/details/${var.region}/dbt-run/executions?project=${var.project_id}

      This indicates a fatal failure (container crash, timeout, OOM, etc.)
    EOT
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s"
  }
}