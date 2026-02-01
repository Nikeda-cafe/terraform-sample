module "ec2" {
  source = "../../modules/ec2"
  env = "prod"
  prefix = "prod-"
}