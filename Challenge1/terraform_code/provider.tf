terraform {
  backend "remote" {
    organization = "DEMO"
    hostname     = "terraform-demo-project.com"
    workspaces {
      name = "AWS_INFRA"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::xxxxxxxxxx:role/TerraformExecutionRole"
    session_name = "Automation_Assume_Role"
  }
}
