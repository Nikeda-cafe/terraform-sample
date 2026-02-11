locals {
  prefix = var.prefix
  region = var.region
}

# 既存の VPC を参照
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# 既存のプライベートサブネットを参照
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

# Interface エンドポイント用セキュリティグループ
resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.prefix}vpc-endpoints-sg"
  description = "Security group for VPC Interface endpoints"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.prefix}vpc-endpoints-sg"
    Environment = var.env
  }
}

# ECR API Interface エンドポイント
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = data.aws_vpc.this.id
  service_name        = "com.amazonaws.${local.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.this.ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${local.prefix}ecr-api"
    Environment = var.env
  }
}

# ECR DKR Interface エンドポイント
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = data.aws_vpc.this.id
  service_name        = "com.amazonaws.${local.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.this.ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${local.prefix}ecr-dkr"
    Environment = var.env
  }
}

# CloudWatch Logs Interface エンドポイント
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = data.aws_vpc.this.id
  service_name        = "com.amazonaws.${local.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.this.ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${local.prefix}logs"
    Environment = var.env
  }
}
