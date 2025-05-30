provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_version = "~> 1.0.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.60.0"
    }
  }
  backend "s3" {
    bucket  = "lesure-tfstate"
    key     = "production.tfstate"
    encrypt = true
  }
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "lesure-tfstate"
  versioning {
    enabled = true
  }
}