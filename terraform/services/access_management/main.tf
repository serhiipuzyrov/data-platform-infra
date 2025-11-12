#########################################
# Terraform Service Account and WIF
#########################################

resource "google_service_account" "terraform_sa" {
  account_id   = "terraform-sa"
  display_name = "Terraform GitHub Actions Service Account"
}

locals {
  terraform_sa_roles = [
    "roles/editor",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin"
  ]
  allowed_repositories = [
    "${var.github_org}/${var.github_repo_infra}",
    "${var.github_org}/${var.github_repo_dbt}"
  ]
}

resource "google_project_iam_member" "terraform_sa_roles" {
  for_each = toset(local.terraform_sa_roles)
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  lifecycle {prevent_destroy = true}
  project = var.project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "OIDC pool for GitHub Actions"
}

# Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  lifecycle {prevent_destroy = true}
  project = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "OIDC provider for GitHub Actions"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }
  # Allow multiple repositories
  attribute_condition = "assertion.repository in ['${join("', '", local.allowed_repositories)}']"
}

# Allow only your repo to impersonate the terraform-sa
resource "google_service_account_iam_member" "github_wif_binding" {
  for_each = toset(local.allowed_repositories)
  service_account_id = google_service_account.terraform_sa.name
  role = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${each.value}"
}

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
    "roles/iam.serviceAccountTokenCreator",
    "roles/run.invoker"
  ]
}

resource "google_project_iam_member" "dbt_sa_roles" {
  for_each = toset(local.dbt_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.dbt_runner.email}"
}

resource "google_service_account_iam_member" "github_wif_dbt_runner" {
  for_each = toset(local.allowed_repositories)
  service_account_id = google_service_account.dbt_runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${each.value}"
}


