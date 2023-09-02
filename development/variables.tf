variable "aws_region" {
  type        = string
  description = "AWS US-East-2 (OHIO)"
  default     = "us-east-2"
}

variable "environment" {
  type        = string
  description = "current environment"
}

variable "ecs_image_ami_id" {
  type        = string
  description = "AMI ID for ECS Image"
}

variable "ecs_instance_type" {
  type        = string
  description = "Instance type for ECS Image"
}

variable "hosted_domain_name" {
  type        = string
  description = "Hosted domain name (route53) zone"
}

