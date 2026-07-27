data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["udemy-aws-container-vpc"]
  }
}

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

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = ["udemy-aws-container-subnet-private*"]
  }
}

module "gitlab" {
  source = "../../modules/ec2"

  environment      = "prod"
  prefix           = "prod-"
  region           = "ap-northeast-1"
  vpc_id           = data.aws_vpc.this.id
  public_subnet_id = data.aws_subnets.public.ids[0]
  instance_type    = "t3.medium"
  root_volume_size = 50
}

module "runner" {
  source = "../../modules/runner"

  environment      = "prod"
  prefix           = "prod-"
  region           = "ap-northeast-1"
  vpc_id           = data.aws_vpc.this.id
  private_subnet_id = data.aws_subnets.private.ids[0]
  gitlab_url         = "http://${module.gitlab.instance_private_ip}"

  runner_token_ssm_parameter_name = aws_ssm_parameter.runner_authentication_token.name

  instance_type    = "t3.small"
  root_volume_size = 30

  depends_on = [
    module.gitlab,
    aws_ssm_parameter.runner_authentication_token,
  ]
}
