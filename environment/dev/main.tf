module "ecr" {
  source          = "../../modules/ecr"
  env             = "dev"
  prefix          = "dev-"
  app_name        = "nextjs-app"
  max_image_count = 10
}

module "ecs" {
  source                   = "../../modules/ecs"
  env                      = "dev"
  prefix                   = "dev-"
  app_name                 = "nextjs-app"
  vpc_name                 = "udemy-aws-container-vpc"
  task_execution_role_name = "ecsTaskExecutionRole"
  ecr_repository_url       = module.ecr.repository_url
  container_port           = 3000
  cpu                      = 256
  memory                   = 512
  image_tag                = "latest"
  subnet_tag_names = [
    "udemy-aws-container-subnet-public1-ap-northeast-1a",
    "udemy-aws-container-subnet-public2-ap-northeast-1c",
  ]
  security_group_name      = "udemy-aws-container-task-sg"
  desired_count            = 1
}
