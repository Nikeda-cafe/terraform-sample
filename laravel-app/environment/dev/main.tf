data "aws_ecr_repository" "laravel_app" {
  name = "laravel-app"
}

data "aws_ecr_repository" "laravel_nginx" {
  name = "laravel-nginx"
}

module "ecs" {
  source                    = "../../modules/ecs"
  env                       = "dev"
  prefix                    = "dev-"
  app_name                  = "laravel-app"
  vpc_name                  = "udemy-aws-container-vpc"
  task_execution_role_name  = "ecsTaskExecutionRole"
  task_role_arn             = "arn:aws:iam::270094330805:role/udemy-aws-container-task-execution-role"
  ecr_app_repository_url    = data.aws_ecr_repository.laravel_app.repository_url
  ecr_nginx_repository_url  = data.aws_ecr_repository.laravel_nginx.repository_url
  container_port            = 80
  cpu                       = 256
  memory                    = 1024
  image_tag                 = "latest"

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
  route53_zone_id     = "Z0463825IEI8PL7L13YI"  # ホストゾーンID
  route53_record_name = "laravel" # サブドメイン

  laravel_environment = {
    APP_ENV        = "production"
    APP_NAME       = "Laravel"
    APP_DEBUG      = "false"
    APP_KEY        = "base64:rRQ9Q/6hcZ0pF6NF0QUyIb3gvCb5LwrOBLdnoFQPvn8="
    SESSION_DRIVER = "database"
    DB_HOST        = "10.0.0.76"
    DB_PORT        = "3306"
    DB_DATABASE    = "app"
    DB_USERNAME    = "app"
    DB_PASSWORD    = "secret"
  }
}
