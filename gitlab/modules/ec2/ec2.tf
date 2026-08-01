resource "aws_instance" "gitlab" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.gitlab.id]
  iam_instance_profile        = aws_iam_instance_profile.gitlab.name
  associate_public_ip_address = true
  monitoring                  = true

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    external_url               = local.external_url
    region                     = var.region
    runner_token_ssm_parameter = var.runner_token_ssm_parameter_name
    docker_default_image       = var.docker_default_image
    runner_description         = var.runner_description
    runner_tag_list            = var.runner_tag_list
  })

  # Re-create instance when bootstrap script changes (user_data runs only on first boot)
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    tags = merge(
      local.common_tags,
      {
        Name = "${local.prefix}gitlab-root"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}gitlab"
    }
  )

  depends_on = [aws_security_group.gitlab]
}
