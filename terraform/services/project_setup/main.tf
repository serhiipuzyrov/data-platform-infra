#########################################
# APIs enabling
#########################################

locals {
  services = [
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "monitoring.googleapis.com",
    "iap.googleapis.com",
    "cloudidentity.googleapis.com"
  ]
}

resource "google_project_service" "services" {
  for_each = toset(local.services)
  project  = var.project_id
  service  = each.value
  disable_on_destroy = false
}
