resource "aws_security_group" "runner" {
  name        = "${local.prefix}gitlab-runner-sg"
  description = "Security group for GitLab Runner (Session Manager only; no inbound)"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}gitlab-runner-sg"
    }
  )
}

resource "aws_security_group_rule" "runner_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.runner.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "GitLab API, Docker pulls, package updates"
}
