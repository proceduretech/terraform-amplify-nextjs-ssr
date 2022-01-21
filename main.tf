# AWS Provider
provider "aws" {
  profile    = var.profile
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Terraform Settings
terraform {
  backend "s3" {
    bucket = ""
    key    = ""
    region = "ap-south-1"
  }
}

# s3 for terraform state
resource "aws_s3_bucket" "terraform-state" {
  bucket = var.state_bucket
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Environment = var.environment
  }
}

module "frontend" {
  source = "./modules/frontend"
  environment  = var.environment
  project_name = var.project_name
  github_repository = var.github_repository
  github_token_for_frontend = var.github_token_for_frontend
}