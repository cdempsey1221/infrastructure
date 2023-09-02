terraform {
  backend "s3" {
    bucket         = "terraform-state-701725317802-dev"
    key            = "infrastructure/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking-dev"
    encrypt        = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

module "vpc-module" {
  source               = "../shared/vpc-module"
  environment          = var.environment
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_security_group" "ecs_security_group" {
  name        = "${var.environment}-ecs-security-group"
  description = "Allow inbounc traffic to ECS cluster"
  vpc_id      = module.vpc-module.vpc_id
  depends_on  = [module.vpc-module]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc-module.cidr_allow_all_traffic]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc-module.cidr_allow_all_traffic]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc-module.cidr_allow_all_traffic]
  }

  ingress {
    from_port   = 8091
    to_port     = 8091
    protocol    = "tcp"
    cidr_blocks = [module.vpc-module.cidr_allow_all_traffic]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc-module.cidr_allow_all_traffic]
  }

  tags = {
    Name = "${var.environment}-ecs-security-group"
  }
}

data "aws_iam_policy_document" "ecs_tasks_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_tasks_cloudwatch_logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "ecs_tasks_cloudwatch_logs_policy" {
  name        = "${var.environment}-ecs-tasks-cloudwatch-logs-policy"
  description = "Permissions for ECS tasks to write to CloudWatch logs"
  policy      = data.aws_iam_policy_document.ecs_tasks_cloudwatch_logs.json
}

resource "aws_iam_role" "ecs_tasks_role" {
  name               = "${var.environment}-ecs-tasks-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_cloudwatch_logs_attachment" {
  role       = aws_iam_role.ecs_tasks_role.name
  policy_arn = aws_iam_policy.ecs_tasks_cloudwatch_logs_policy.arn
}

locals {
  ecs_cluster_name = "${var.environment}-ecs-cluster"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.ecs_cluster_name
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

# create Route53 zone shared accross all environments
resource "aws_route53_zone" "main-zone" {
  name = var.hosted_domain_name
}

output "route53_main_zone_id" {
  value = aws_route53_zone.main-zone.zone_id
}

module "hello_world_svc" {
  source                      = "../app-deployments/hello-world-service"
  environment                 = var.environment
  vpc_id                      = module.vpc-module.vpc_id
  ecs_cluster_id              = aws_ecs_cluster.ecs_cluster.id
  public_subnet_ids           = module.vpc-module.public_subnet_ids
  ecs_task_execution_role_arn = aws_iam_role.ecs_tasks_role.arn
  route53_main_zone_id        = aws_route53_zone.main-zone.zone_id
}
