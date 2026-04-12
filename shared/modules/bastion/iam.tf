# IAM Role for Bastion EC2 Instance
resource "aws_iam_role" "bastion" {
  name               = "${local.prefix}bastion-role"
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
      Name = "${local.prefix}bastion-role"
    }
  )
}

# Attach AWS managed policy for Systems Manager Session Manager
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile for Bastion
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.prefix}bastion-profile"
  role = aws_iam_role.bastion.name
}
