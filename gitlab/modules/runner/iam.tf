resource "aws_iam_role" "runner" {
  name = "${local.prefix}gitlab-runner-role"
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
      Name = "${local.prefix}gitlab-runner-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "runner_ssm" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_ssm_parameter" "runner_token" {
  name = var.runner_token_ssm_parameter_name
}

resource "aws_iam_role_policy" "runner_token_read" {
  name = "${local.prefix}gitlab-runner-token-read"
  role = aws_iam_role.runner.id

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

resource "aws_iam_instance_profile" "runner" {
  name = "${local.prefix}gitlab-runner-profile"
  role = aws_iam_role.runner.name
}
