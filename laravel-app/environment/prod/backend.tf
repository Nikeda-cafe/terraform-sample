terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "laravel-app/prod/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
