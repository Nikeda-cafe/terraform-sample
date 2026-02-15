terraform {
  backend "s3" {
    bucket = "sample-terraform-state-bucket-na"
    key    = "nextjs-app/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
