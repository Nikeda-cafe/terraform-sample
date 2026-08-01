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

module "gitlab" {
  source = "../../modules/ec2"

  environment      = "prod"
  prefix           = "prod-"
  region           = "ap-northeast-1"
  vpc_id           = data.aws_vpc.this.id
  public_subnet_id = data.aws_subnets.public.ids[0]
  instance_type    = "t3.large"
  root_volume_size = 60

  runner_token_ssm_parameter_name = aws_ssm_parameter.runner_authentication_token.name

  depends_on = [aws_ssm_parameter.runner_authentication_token]
}
