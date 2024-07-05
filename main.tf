terraform {
  backend "remote" {
    organization = "sakhile-org"
    workspaces {
      prefix = "medium-app-"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "current" {}