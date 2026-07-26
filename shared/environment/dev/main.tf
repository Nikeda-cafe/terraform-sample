module "vpc_endpoints" {
  source   = "../../modules/vpc-endpoints"
  env      = "dev"
  prefix   = "dev-"
  vpc_name = "udemy-aws-container-vpc"
  subnet_tag_names = [
    "udemy-aws-container-subnet-private1-ap-northeast-1a",
    "udemy-aws-container-subnet-private2-ap-northeast-1c",
  ]
  region = "ap-northeast-1"
}

# Reference existing VPC for security group lookup
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["udemy-aws-container-vpc"]
  }
}

# ECS Fargate などアプリタスク用 SG（既存）— RDS から 3306 を許可する
data "aws_security_group" "ecs_tasks" {
  filter {
    name   = "group-name"
    values = ["udemy-aws-container-task-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment = var.environment
  prefix      = var.prefix
  region      = var.region
  vpc_name    = "udemy-aws-container-vpc"
  subnet_tag_names = [
    "udemy-aws-container-subnet-private1-ap-northeast-1a",
    "udemy-aws-container-subnet-private2-ap-northeast-1c",
  ]
  db_name                           = var.db_name
  db_master_username                = var.db_master_username
  db_master_password                = var.db_master_password
  allocated_storage                 = var.allocated_storage
  storage_type                      = var.storage_type
  engine_version                    = var.engine_version
  backup_retention_period           = var.backup_retention_period
  skip_final_snapshot               = var.skip_final_snapshot
  allowed_client_security_group_ids = [data.aws_security_group.ecs_tasks.id]
  tags                              = var.tags
}
