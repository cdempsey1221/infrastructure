provider "aws" {
  region = var.aws_region
}

resource "aws_cloudwatch_log_group" "hello_svc_logs" {
  name = "/ecs/hello-world-svc"
}

resource "aws_security_group" "hello_world_svc_sg" {
  name        = "${var.environment}-hello_world_svc_sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 8091
    to_port         = 8091
    security_groups = [aws_security_group.hello_world_svc_alb_sg.id]
  }

  # allow all outbound traffic
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hello_world_svc_alb_sg" {
  name        = "${var.environment}-hello-world-svc-alb-sg"
  description = "Allow all inbound traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow all traffic
  }

  # allow all traffic outbound
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-hello-world-svc-alb-sg"
  }
}

resource "aws_lb" "hello_world_svc_alb" {
  name               = "${var.environment}-hello-world-svc-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.hello_world_svc_alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.environment}-hello-world-svc-alb"
  }
}

resource "aws_lb_target_group" "hello_world_svc_alb_tg" {
  name       = "${var.environment}-hello-world-svc-alb-tg"
  port       = 80
  protocol   = "HTTP"
  target_type = "ip"
  vpc_id     = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/actuator/health"
    port                = "traffic-port"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 5
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.environment}-hello-world-svc-alb-tg"
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.hello_world_svc_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_world_svc_alb_tg.arn
    type             = "forward"
  }
}

data "template_file" "hello_world_svc_task_definition" {
  template = file("${path.module}/hello_world_svc_task_def.json.tpl")
}

resource "aws_ecs_task_definition" "hello_world_svc_task" {
  family                = "hello-world-svc"
  container_definitions = data.template_file.hello_world_svc_task_definition.rendered
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"
  execution_role_arn = var.ecs_task_execution_role_arn

  tags = {
    Name = "hello-world-svc"
  }
}

resource "aws_ecs_service" "hello_world_svc" {
  name            = "hello-world-svc"
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  task_definition = aws_ecs_task_definition.hello_world_svc_task.arn
  desired_count   = 1

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.hello_world_svc_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_world_svc_alb_tg.arn
    container_name   = "hello-world-svc"
    container_port   = 8091
  }

  tags = {
    Name = "hello-world-svc"
  }
}
