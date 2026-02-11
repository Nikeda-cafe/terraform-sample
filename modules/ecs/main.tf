locals {
  prefix = var.prefix
  region = var.region
}

# 既存のVPCを参照
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# 既存のサブネットを参照（ECS タスク用）
data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = var.subnet_tag_names
  }
}

# ALB 用パブリックサブネット
data "aws_subnets" "alb" {
  count = var.enable_load_balancer ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = var.alb_subnet_tag_names
  }
}

# 既存のセキュリティグループを参照
data "aws_security_group" "this" {
  filter {
    name   = "group-name"
    values = [var.security_group_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

# 既存のIAMロールを参照（タスク実行ロール）
data "aws_iam_role" "task_execution" {
  name = var.task_execution_role_name
}

# ECS クラスター
resource "aws_ecs_cluster" "this" {
  name = "${local.prefix}${var.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = var.env == "prod" ? "enabled" : "disabled"
  }

  tags = {
    Name        = "${local.prefix}${var.app_name}-cluster"
    Environment = var.env
  }
}

# 現在のリージョンを取得
data "aws_region" "current" {}

# CloudWatch Logs グループ
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${local.prefix}${var.app_name}"
  retention_in_days = var.env == "prod" ? 30 : 7

  tags = {
    Name        = "/ecs/${local.prefix}${var.app_name}"
    Environment = var.env
  }
}

# ECS タスク定義
resource "aws_ecs_task_definition" "this" {
  family                   = "${local.prefix}${var.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = data.aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = "${var.ecr_repository_url}:${var.image_tag}"

      portMappings = [
        {
          name          = "${var.app_name}-port"
          containerPort = var.container_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      # ここを追加
      environment = [
        {
          name  = "NODE_ENV"
          value = var.env == "prod" ? "production" : "development"
        },
        {
          name  = "PORT"
          value = tostring(var.container_port)
        },
        {
          name  = "HOSTNAME"
          value = "0.0.0.0"
        }
      ]

      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = local.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${local.prefix}${var.app_name}"
    Environment = var.env
  }
}

# ALB セキュリティグループ
resource "aws_security_group" "alb" {
  count = var.enable_load_balancer ? 1 : 0

  name        = "${local.prefix}${var.app_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.prefix}${var.app_name}-alb-sg"
    Environment = var.env
  }
}

# ALB → ECS タスクへのインバウンド許可
resource "aws_security_group_rule" "alb_to_ecs" {
  count = var.enable_load_balancer ? 1 : 0

  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb[0].id
  security_group_id        = data.aws_security_group.this.id
  description              = "Allow traffic from ALB to ECS tasks"
}

# Application Load Balancer
resource "aws_lb" "this" {
  count = var.enable_load_balancer ? 1 : 0

  name               = "${local.prefix}${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = data.aws_subnets.alb[0].ids

  tags = {
    Name        = "${local.prefix}${var.app_name}-alb"
    Environment = var.env
  }
}

# ターゲットグループ
resource "aws_lb_target_group" "this" {
  count = var.enable_load_balancer ? 1 : 0

  name        = "${local.prefix}${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.this.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${local.prefix}${var.app_name}-tg"
    Environment = var.env
  }
}

# HTTPS リスナー
resource "aws_lb_listener" "https" {
  count = var.enable_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}

# HTTP リスナー（HTTPS へリダイレクト）
resource "aws_lb_listener" "http" {
  count = var.enable_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ECS サービス
resource "aws_ecs_service" "this" {
  name            = "${local.prefix}${var.app_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # ローリングアップデート設定
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  dynamic "load_balancer" {
    for_each = var.enable_load_balancer ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = var.app_name
      container_port   = var.container_port
    }
  }

  network_configuration {
    subnets          = data.aws_subnets.this.ids
    security_groups  = [data.aws_security_group.this.id]
    assign_public_ip = !var.enable_load_balancer
  }

  tags = {
    Name        = "${local.prefix}${var.app_name}-service"
    Environment = var.env
  }
}
