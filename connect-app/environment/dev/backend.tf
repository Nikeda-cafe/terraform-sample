terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "connect-app/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
