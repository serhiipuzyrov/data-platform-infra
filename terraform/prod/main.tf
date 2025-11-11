terraform {
  required_version = "1.13.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.84.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "tf-state-data-platform-prod-477621"
    prefix = "terraform/state"
  }
}

module "project_setup" {
  source     = "../services/project_setup"
  project_id = var.project_id
}

module "bigquery" {
  source     = "../services/bigquery"
  project_id = var.project_id
  multi_region     = var.multi_region
  region     = var.region
}

module "dbt" {
  source     = "../services/dbt"
  project_id = var.project_id
  region     = var.region
  env = var.env
  depends_on = [module.project_setup]
}

module "iam_users" {
  source     = "../services/iam_users"
  project_id = var.project_id
  region     = var.region
}

module "workload_identity_federation" {
  source     = "../services/workload_identity_federation"
  project_id = var.project_id
  region     = var.region
  github_org = var.github_org
  github_repo_infra = var.github_repo_infra
  github_repo_dbt = var.github_repo_dbt
}