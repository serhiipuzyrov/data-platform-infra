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
        fetch cloud_run_job
        | metric 'run.googleapis.com/job/completed_execution_count'
        | filter resource.job_name == 'dbt-run'
        | align rate(1m)
        | every 1m
        | group_by [resource.job_name, metric.result],
            [value_completed_execution_count_aggregate: aggregate(value.completed_execution_count)]
        | filter metric.result == 'failed'
        | condition value_completed_execution_count_aggregate > 0
      EOT
      duration = "0s"
      trigger {
        count = 1
      }
    }
  }
  notification_channels = [google_monitoring_notification_channel.email_channel.name]
  alert_strategy {
    notification_prompts = ["OPENED"]
    auto_close = "86400s" # 24 hours
  }
}