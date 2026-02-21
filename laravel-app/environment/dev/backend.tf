terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "laravel-app/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
