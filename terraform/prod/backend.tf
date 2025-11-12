terraform {
  required_version = "1.13.5"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.84.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region
}

terraform {
  backend "gcs" {
    bucket = "tf-state-data-platform-prod-477621"  # Dev environment
    prefix = "terraform/state"
  }
}
