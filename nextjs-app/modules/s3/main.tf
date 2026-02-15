locals {
  prefix = var.prefix
  region = var.region
}

# S3バケット
resource "aws_s3_bucket" "this" {
  bucket = "${local.prefix}${var.bucket_name}"

  tags = {
    Name        = "${local.prefix}${var.bucket_name}"
    Environment = var.env
  }
}

# バケットバージョニング
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }

  lifecycle {
    ignore_changes = [versioning_configuration]
  }
}

# パブリックアクセスブロック
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets  = true
}

# サーバーサイド暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  lifecycle {
    ignore_changes = [rule]
  }
}

# ライフサイクル設定（オプション）
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.enable_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = var.transition_to_glacier_days
      storage_class = "GLACIER"
    }
  }

  rule {
    id     = "expiration"
    status = var.enable_expiration ? "Enabled" : "Disabled"

    expiration {
      days = var.expiration_days
    }
  }
}
