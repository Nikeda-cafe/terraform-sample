# ECR リポジトリ名は既存環境に合わせて調整してください
data "aws_ecr_repository" "express_app" {
  name = "prod-express-app"
}

module "ecs" {
  source                   = "../../modules/ecs"
  env                      = "prod"
  prefix                   = "prod-"
  app_name                 = "express-app"
  vpc_name                 = "udemy-aws-container-vpc"
  task_execution_role_name = "ecsTaskExecutionRole"
  ecr_repository_url       = data.aws_ecr_repository.express_app.repository_url
  container_port           = 3001
  cpu                      = 256
  memory                   = 512
  image_tag                = "latest"
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
}
