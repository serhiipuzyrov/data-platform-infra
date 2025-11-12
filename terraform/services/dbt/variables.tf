variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "env" {
  type        = string
}

variable "dbt_runner_email" {
  type        = string
}
