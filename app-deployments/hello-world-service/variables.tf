variable "aws_region" {
  type        = string
  description = "AWS US-East-2 (OHIO)"
  default     = "us-east-2"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "environment" {
  type        = string
  description = "selected environment"
}

variable "ecs_cluster_id" {
  type        = string
  description = "ECS cluster id"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet ids"
}

variable "ecs_security_group" {
  type        = string
  description = "ECS security group"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "ECS task execution role"
}
