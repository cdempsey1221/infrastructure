terraform {
  #comment entire backend out if you want to use local state
  # backend "s3" {
  #   bucket         = "terraform-state-701725317802-dev"
  #   key            = "infrastructure/dev/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "terraform-state-locking-dev"
  #   encrypt        = true
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# create data object to get AWS account ID
data "aws_caller_identity" "current" {}

# create terraform s3 bucket name to be unique based on AWS account ID
locals {
  terraform_state_bucket_name = "terraform-state-${data.aws_caller_identity.current.account_id}-dev"
}

output "terraform_state_bucket_name" {
  description = "Terraform S3 state bucket name"
  value       = local.terraform_state_bucket_name
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = local.terraform_state_bucket_name

  tags = {
    Name = local.terraform_state_bucket_name
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_versioning" "terraform-bucket-versioning" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-bucket-encryption" {
  bucket = aws_s3_bucket.terraform-state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_encryption_cipher
    }
  }
}

# setup dynamodb table for terraform state locking
resource "aws_dynamodb_table" "terraform-state-locking-dev" {
  name         = "terraform-state-locking-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}
