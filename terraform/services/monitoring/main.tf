#########################################
# DBT jobs monitoring and alerting
#########################################
resource "google_monitoring_notification_channel" "email_channel" {
  display_name = "DBT Job Failure Alert"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

resource "google_monitoring_alert_policy" "dbt_job_failure" {
  display_name = "DBT Cloud Run Job Failure Alert"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "DBT job failed"

    condition_monitoring_query_language {
      query = <<-EOT
        fetch cloud_run_job_run
        | filter resource.job_name == "dbt-run"
        | filter metric.job_run_completion_count > 0
        | group_by [resource.job_name],
            [completed: sum(metric.job_run_completion_count)]
        | join (
            fetch cloud_run_job_run
            | filter resource.job_name == "dbt-run"
            | filter metric.job_run_failed_count > 0
            | group_by [resource.job_name],
                [failed: sum(metric.job_run_failed_count)]
          ),
          on = [resource.job_name]
        | value [failed / completed]
        | condition val() > 0
      EOT
      duration = "60s" # how long condition must hold before alert fires
      trigger {
        count = 1
      }
    }
  }
  notification_channels = [google_monitoring_notification_channel.email_channel.name]
}
