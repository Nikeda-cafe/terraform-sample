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
