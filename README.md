# GCP Data Engineering Infrastructure Template

A Terraform-based template for bootstrapping Data Engineering projects on Google Cloud Platform. This template sets up infrastructure for DBT and implements CI/CD pipelines for both development and production environments.

## 📋 Overview

This repository provides a ready-to-use infrastructure setup that includes:
- Terraform state management
- Multi-environment configuration (dev/prod)
- DBT integration
- CI/CD pipeline automation

## 🔧 Configuration

### Global Settings

| Parameter                | Value                 |
|--------------------------|-----------------------|
| **GitHub Account**       | `serhiipuzyrov`       |
| **Terraform Repository** | `data-platform-infra` |
| **DBT Repository**       | `data-platform-dbt`   |

### GCP Development Environment

| Parameter | Value |
|-----------|-------|
| **Project ID** | `data-platform-dev-477621` |
| **Terraform State Bucket** | `tf-state-data-platform-dev-477621` |
| **Multi-region** | `EU` |
| **Region** | `europe-central2` |

### GCP Production Environment

| Parameter | Value |
|-----------|-------|
| **Project ID** | `data-platform-prod-477621` |
| **Terraform State Bucket** | `tf-state-data-platform-prod-477621` |
| **Multi-region** | `EU` |
| **Region** | `europe-central2` |

## 🚀 Getting Started

1. Clone this repository
2. Update the configuration values in the tables above to match your GCP projects
3. Configure your Terraform backend
4. Run `terraform init` to initialize the infrastructure
5. Deploy using `terraform apply`

## 📝 Notes

Make sure to replace all configuration values with your own project details before deployment.