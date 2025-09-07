terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # No backend block needed when using Terraform Cloud (VCS workflow).
}

provider "aws" {
  region = var.aws_region
}