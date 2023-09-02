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

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "ECS task execution role"
}
variable "route53_main_zone_id" {
  type        = string
  description = "Route53 main zone id"
}

variable "hello_world_service_name" {
  type        = string
  description = "service name used for Hello World ECS task/service"
  default     = "hello-world-svc"
}
