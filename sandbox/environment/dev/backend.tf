terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "sandbox/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
