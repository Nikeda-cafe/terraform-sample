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
  external_url = coalesce(var.external_url, "http://${aws_eip.gitlab.public_ip}")

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "gitlab-ec2"
    }
  )
}

data "aws_ssm_parameter" "ubuntu_2204_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}
