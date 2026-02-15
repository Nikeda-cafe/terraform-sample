terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "express-app/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
