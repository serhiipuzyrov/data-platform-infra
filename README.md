# GCP Data Engineering Infrastructure Template

A Terraform-based template for bootstrapping Data Engineering projects on Google Cloud Platform. This template sets up infrastructure for DBT and implements CI/CD pipelines for both development and production environments.
This repository is a part of global project which contains:

| Project       | GitHub repository                                     |
|---------------|-------------------------------------------------------|
| **Terraform** | https://github.com/serhiipuzyrov/data-platform-infra  |
| **DBT**       | https://github.com/serhiipuzyrov/data-platform-dbt    |

## 📋 Overview

This repository provides a ready-to-use infrastructure setup that includes:
- Terraform state management
- Multi-environment configuration (dev/prod)
- DBT infrastructure creation (Cloud Run Jobs & Cloud Scheduler)
- CI/CD pipeline automation
- Cloud Monitoring Alerts

## 🔧 Configuration

### Global Settings

| Parameter                       | Value                      |
|---------------------------------|----------------------------|
| **GitHub Account**              | `serhiipuzyrov`            |
| **Terraform GitHub Repository** | `data-platform-infra`      |
| **DBT GitHub Repository**       | `data-platform-dbt`        |
| **Multi-region**                | `EU`                       |
| **Region**                      | `europe-central2`          |
| **Alert Email**                 | `serhii.puzyrov@gmail.com` |
| **Organization Domain**         | `pipelinica.com`           |

### GCP Development Environment

| Parameter                   | Value                                |
|-----------------------------|--------------------------------------|
| **Project ID**              | `data-platform-dev-477621`           |
| **Terraform State Bucket**  | `tf-state-data-platform-dev-477621`  |

### GCP Production Environment

| Parameter                  | Value                                 |
|----------------------------|---------------------------------------|
| **Project ID**             | `data-platform-prod-477621`           |
| **Terraform State Bucket** | `tf-state-data-platform-prod-477621`  |

## 🚀 Getting Started

1. Clone this repository
2. Update the configuration values in the tables above to match your GCP projects
3. Configure your Terraform backend
4. Log into You GCP account: gcloud auth application-default login
5. Navigate to DEV environment: cd terraform/dev
6. Run `terraform init` to initialize the infrastructure
7. Deploy using `terraform apply`
8. Push project to Your GitHub

## 📝 Notes

Make sure to replace all configuration values with your own project details before deployment.