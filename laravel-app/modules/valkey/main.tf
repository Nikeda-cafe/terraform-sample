# 既存 VPC を参照
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# 既存プライベートサブネットを参照
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

# ECS タスク用セキュリティグループを参照
data "aws_security_group" "ecs" {
  filter {
    name   = "group-name"
    values = [var.ecs_security_group_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

# ElastiCache サブネットグループ
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.prefix}laravel-app-valkey-subnet"
  subnet_ids = data.aws_subnets.this.ids

  tags = {
    Name        = "${var.prefix}laravel-app-valkey-subnet"
    Environment = var.env
  }
}

# Valkey 用セキュリティグループ（ECS タスク SG からの 6379 インバウンド許可）
resource "aws_security_group" "valkey" {
  name        = "${var.prefix}laravel-app-valkey-sg"
  description = "Security group for Valkey cache - allow from ECS tasks"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [data.aws_security_group.ecs.id]
    description     = "Allow Redis/Valkey from ECS tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.prefix}laravel-app-valkey-sg"
    Environment = var.env
  }
}

# ElastiCache for Valkey レプリケーショングループ
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.prefix}laravel-app-valkey"
  description          = "Valkey cache for Laravel app (${var.env})"

  engine               = "valkey"
  engine_version       = "7.2"
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_clusters
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.valkey.id]

  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled          = var.multi_az_enabled

  tags = {
    Name        = "${var.prefix}laravel-app-valkey"
    Environment = var.env
  }
}
