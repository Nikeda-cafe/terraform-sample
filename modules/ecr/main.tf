locals {
  prefix = var.prefix
}

# ECR リポジトリ
resource "aws_ecr_repository" "this" {
  name                 = "${local.prefix}${var.app_name}"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.env == "dev" ? true : false

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${local.prefix}${var.app_name}"
    Environment = var.env
  }
}

# ライフサイクルポリシー: 古いイメージを自動削除
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last ${var.max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
