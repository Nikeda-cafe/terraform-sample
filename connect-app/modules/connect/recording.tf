# 通話録音を保存する S3 バケット（PoC のためコストを抑えバージョニング・ライフサイクルは設定しない）
resource "aws_s3_bucket" "call_recordings" {
  bucket = "${local.prefix}${var.recording_bucket_name}"

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "call_recordings" {
  bucket = aws_s3_bucket.call_recordings.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "call_recordings" {
  bucket = aws_s3_bucket.call_recordings.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 バケットを Connect インスタンスの通話録音保存先として関連付ける
resource "aws_connect_instance_storage_config" "call_recordings" {
  instance_id   = aws_connect_instance.this.id
  resource_type = "CALL_RECORDINGS"

  storage_config {
    storage_type = "S3"

    s3_config {
      bucket_name   = aws_s3_bucket.call_recordings.bucket
      bucket_prefix = "recordings"
    }
  }
}
