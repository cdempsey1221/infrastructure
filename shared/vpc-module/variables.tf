variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "Public subnet CIDR blocks for the DEV environment"
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "Public subnet CIDR blocks for the DEV environment"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "aws_availability_zones" {
  type        = list(string)
  description = "AWS Availability Zones for US-East-2 (OHIO)"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "aws_region" {
  type        = string
  description = "AWS US-East-2 (OHIO)"
  default     = "us-east-2"
}

variable "cidr_allow_all_traffic" {
  type        = string
  description = "current environment"
  default     = "0.0.0.0/0"
}

variable "environment" {
  type        = string
  description = "current environment"
}

variable "enable_dns_support" {
  type        = bool
  description = "enable dns support in VPC" 
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "enable dns hostnames in VPC" 
}