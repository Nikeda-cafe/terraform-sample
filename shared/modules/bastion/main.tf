terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.30.0"
    }
  }
}

locals {
  prefix      = var.prefix
  region      = var.region
  environment = var.environment
  
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "bastion"
    }
  )
}

# Get latest Amazon Linux 2023 AMI using Systems Manager parameter
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.al2023_ami.value]
  }
}
