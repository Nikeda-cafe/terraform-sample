terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "express-app/prod/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
