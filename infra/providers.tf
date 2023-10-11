terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
  }

  backend "s3" {
    encrypt = "true"
  }

  required_version = ">= 1.2.3"
}

provider "aws" {
  region  = var.region
  default_tags {
    tags = {
      Team = var.team
      Application = var.application
      Environment = var.environment
    }
  }
}