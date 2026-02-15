terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "shared/prod/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
