terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
