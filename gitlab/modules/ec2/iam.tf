resource "aws_iam_role" "gitlab" {
  name = "${local.prefix}gitlab-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}gitlab-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "gitlab_ssm" {
  role       = aws_iam_role.gitlab.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_ssm_parameter" "runner_token" {
  name = var.runner_token_ssm_parameter_name
}

resource "aws_iam_role_policy" "gitlab_runner_token_read" {
  name = "${local.prefix}gitlab-runner-token-read"
  role = aws_iam_role.gitlab.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
        ]
        Resource = data.aws_ssm_parameter.runner_token.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.${var.region}.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "gitlab" {
  name = "${local.prefix}gitlab-profile"
  role = aws_iam_role.gitlab.name
}
