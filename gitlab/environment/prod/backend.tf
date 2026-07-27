terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "gitlab/prod/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
