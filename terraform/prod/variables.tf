variable "project_id" {
  description = "GCP project id"
  type        = string
  default     = "data-platform-prod-477621"
}

variable "env" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "multi_region" {
  type    = string
  default = "EU"
}

variable "github_org" {
  type    = string
  default = "serhiipuzyrov"
}

variable "github_repo_infra" {
  type    = string
  default = "data-platform-infra"
}

variable "github_repo_dbt" {
  type    = string
  default = "data-platform-dbt"
}