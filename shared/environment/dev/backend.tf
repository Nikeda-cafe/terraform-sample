terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "shared/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
