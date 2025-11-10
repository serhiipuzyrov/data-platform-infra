# Terraform CI Service Account
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
    "roles/iam.serviceAccountTokenCreator"
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
  project = var.project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "OIDC pool for GitHub Actions"
}

# Workload Identity Provider (GitHub)
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "OIDC provider for GitHub Actions"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  # Only map attributes; do NOT set attribute_condition here
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }
  # Add attribute condition to restrict to your repository
  attribute_condition = "assertion.repository == '${var.github_org}/${var.github_repo}'"
}

# Allow only your repo to impersonate the terraform-sa
resource "google_service_account_iam_member" "github_wif_binding" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  # The attribute below must match the mapping defined above
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_org}/${var.github_repo}"
}
