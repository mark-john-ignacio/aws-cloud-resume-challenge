terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }

  backend "s3" {
    bucket         = var.bucket_name_for_state
    key            = var.state_key
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = "terraform-lock-table" # Optional, for state locking
  }
}

provider "aws" {
  region = var.aws_region
}

