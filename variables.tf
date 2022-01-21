# Configuration Variables
variable "environment" {
  description = "Environment for the resources"
}

variable "profile" {
    description = "AWS profile"
}

variable "project_name" {
  description = "Project name"
}

variable "github_token_for_frontend" {
  description = "Github personal access token for amplify to access the frontend repo"
}

variable "state_bucket" {
    description = "name of the s3 bucket to store s3 state in"
}

variable "state_bucket_key" {
    description = "key in state bucket"
}

variable "region" {
    description = "AWS region"
}

variable "access_key" {
    description = "AWS access key"
}

variable "secret_key" {
    description = "Aws secret access key"
}

variable "github_repository" {
    description = "http link of the github repo"
}