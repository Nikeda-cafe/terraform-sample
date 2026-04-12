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

# Reference existing VPC for Bastion subnet lookup
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["udemy-aws-container-vpc"]
  }
}

# Get public subnet for Bastion
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = ["udemy-aws-container-subnet-public*"]
  }
}

# RDS Module
module "rds" {
  source = "../../modules/rds"
  
  environment              = var.environment
  prefix                   = var.prefix
  region                   = var.region
  vpc_name                 = "udemy-aws-container-vpc"
  subnet_tag_names = [
    "udemy-aws-container-subnet-private1-ap-northeast-1a",
    "udemy-aws-container-subnet-private2-ap-northeast-1c",
  ]
  db_name                  = var.db_name
  db_master_username       = var.db_master_username
  db_master_password       = var.db_master_password
  allocated_storage        = var.allocated_storage
  storage_type             = var.storage_type
  engine_version           = var.engine_version
  backup_retention_period  = var.backup_retention_period
  skip_final_snapshot      = var.skip_final_snapshot
  bastion_security_group_id = module.bastion.security_group_id
  tags                     = var.tags
}

# Bastion Module
module "bastion" {
  source = "../../modules/bastion"
  
  environment              = var.environment
  prefix                   = var.prefix
  region                   = var.region
  vpc_id                   = data.aws_vpc.this.id
  vpc_cidr                 = data.aws_vpc.this.cidr_block
  public_subnet_id         = data.aws_subnets.public.ids[0]
  instance_type            = var.bastion_instance_type
  rds_security_group_id    = module.rds.rds_security_group_id
  tags                     = var.tags
}
