terraform {
  backend "s3" {
    bucket = "udacity-tf-cevasco"  # Update here with your S3 bucket
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72.0"  # Update to a version compatible with your state
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = local.tags
  }
}
