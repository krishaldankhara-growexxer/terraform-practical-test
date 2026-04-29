terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.cross_account_role_arn
    session_name = "TerraformCrossAccountSession"
  }

  default_tags {
    tags = {
      owner       = var.owner
      project     = var.project
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}
