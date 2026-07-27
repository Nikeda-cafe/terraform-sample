resource "aws_instance" "runner" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.runner.id]
  iam_instance_profile        = aws_iam_instance_profile.runner.name
  associate_public_ip_address = false
  monitoring                  = true

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    region                      = var.region
    gitlab_url                  = var.gitlab_url
    runner_token_ssm_parameter  = var.runner_token_ssm_parameter_name
    docker_default_image        = var.docker_default_image
    runner_description          = var.runner_description
    runner_tag_list             = var.runner_tag_list
  })

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    tags = merge(
      local.common_tags,
      {
        Name = "${local.prefix}gitlab-runner-root"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}gitlab-runner"
    }
  )

  depends_on = [aws_security_group.runner]
}
