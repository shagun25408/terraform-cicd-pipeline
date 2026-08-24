terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Create S3 bucket
resource "aws_s3_bucket" "terraform_demo" {
  bucket = "shagun-terraform-cicd-demo-2026"
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "terraform_demo" {
  bucket = aws_s3_bucket.terraform_demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_demo" {
  bucket = aws_s3_bucket.terraform_demo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

