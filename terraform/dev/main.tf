module "project_setup" {
  source = "../services/project_setup"
  project_id = var.project_id
}

module "bigquery" {
  source = "../services/bigquery"
  project_id = var.project_id
  multi_region = var.multi_region
  region = var.region
  depends_on = [module.project_setup]
}

module "dbt" {
  source = "../services/dbt"
  project_id = var.project_id
  project_number = var.project_number
  region = var.region
  env = var.env
  dbt_runner_email = module.access_management.dbt_runner_email
  depends_on = [module.project_setup]
}

module "access_management" {
  source = "../services/access_management"
  project_id = var.project_id
  region = var.region
  env = var.env
  github_org = var.github_org
  github_repo_infra = var.github_repo_infra
  github_repo_dbt = var.github_repo_dbt
  depends_on = [module.project_setup]
}

module "monitoring" {
  source = "../services/monitoring"
  alert_email = var.alert_email
}