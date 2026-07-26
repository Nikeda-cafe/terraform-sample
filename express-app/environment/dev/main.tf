data "aws_ecr_repository" "express_app" {
  name = "express-app"
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = "sample-terraform-state-bucket-na"
    key    = "shared/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

locals {
  database_url = format(
    "mysql://%s:%s@%s:%s/%s",
    data.terraform_remote_state.shared.outputs.rds_master_username,
    urlencode(var.rds_master_password),
    data.terraform_remote_state.shared.outputs.rds_address,
    data.terraform_remote_state.shared.outputs.rds_port,
    data.terraform_remote_state.shared.outputs.rds_database_name,
  )
}

module "ecs" {
  source                   = "../../modules/ecs"
  env                      = "dev"
  prefix                   = "dev-"
  app_name                 = "express-app"
  vpc_name                 = "udemy-aws-container-vpc"
  task_execution_role_name = "ecsTaskExecutionRole"
  ecr_repository_url       = data.aws_ecr_repository.express_app.repository_url
  container_port           = 3000
  cpu                      = 256
  memory                   = 512
  image_tag                = "latest"
  bake_time_in_minutes     = 5
  subnet_tag_names = [
    "udemy-aws-container-subnet-private1-ap-northeast-1a",
    "udemy-aws-container-subnet-private2-ap-northeast-1c",
  ]
  security_group_name = "udemy-aws-container-task-sg"
  desired_count       = 1

  enable_load_balancer = true
  alb_subnet_tag_names = [
    "udemy-aws-container-subnet-public1-ap-northeast-1a",
    "udemy-aws-container-subnet-public2-ap-northeast-1c",
  ]
  acm_certificate_arn = "arn:aws:acm:ap-northeast-1:270094330805:certificate/0713f5b6-e742-4308-a563-30db7cdd5238"

  route53_zone_id     = "Z0463825IEI8PL7L13YI"
  route53_record_name = "express"

  api_gateway_url = "https://jki9aqsy20.execute-api.ap-northeast-1.amazonaws.com/default"
  database_url    = local.database_url
}
