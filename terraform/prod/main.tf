terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.84.0"
    }
  }
  required_version = ">= 1.3.0"
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

variable "project_id" {
  description = "GCP project id"
  type        = string
  default     = "data-platform-prod-477621"
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

variable "github_repo" {
  type    = string
  default = "data-platform-infra"
}


