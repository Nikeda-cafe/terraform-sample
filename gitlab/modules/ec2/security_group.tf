resource "aws_security_group" "gitlab" {
  name        = "${local.prefix}gitlab-sg"
  description = "Security group for GitLab CE EC2 (HTTP/HTTPS; admin via Session Manager)"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}gitlab-sg"
    }
  )
}

resource "aws_security_group_rule" "gitlab_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.gitlab.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "GitLab HTTP"
}

resource "aws_security_group_rule" "gitlab_https_inbound" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.gitlab.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "GitLab HTTPS"
}

resource "aws_security_group_rule" "gitlab_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.gitlab.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outbound (packages, GitLab updates, Let us Encrypt)"
}
