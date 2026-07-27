resource "aws_eip" "gitlab" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}gitlab-eip"
    }
  )
}

resource "aws_eip_association" "gitlab" {
  allocation_id = aws_eip.gitlab.id
  instance_id   = aws_instance.gitlab.id
}
