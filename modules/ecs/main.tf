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

# 既存のサブネットを参照
data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = [var.subnet_tag_name]
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

  network_configuration {
    subnets          = data.aws_subnets.this.ids
    security_groups  = [data.aws_security_group.this.id]
    assign_public_ip = true
  }

  tags = {
    Name        = "${local.prefix}${var.app_name}-service"
    Environment = var.env
  }
}
