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

resource "aws_iam_instance_profile" "gitlab" {
  name = "${local.prefix}gitlab-profile"
  role = aws_iam_role.gitlab.name
}
