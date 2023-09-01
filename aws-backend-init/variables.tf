variable "aws_region" {
  type        = string
  description = "AWS US-East-2 (OHIO)"
  default     = "us-east-2"
}

variable "environment" {
  type        = string
  description = "current environment"
}

variable "s3_encryption_cipher" {
  type        = string
  description = "S3 encryption cipher"
}
