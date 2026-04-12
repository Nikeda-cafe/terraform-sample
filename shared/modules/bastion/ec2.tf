# EC2 Bastion Instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  
  user_data = file("${path.module}/user_data.sh")
  
  associate_public_ip_address = true
  monitoring                  = true
  
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    tags = merge(
      local.common_tags,
      {
        Name = "${local.prefix}bastion-root"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}bastion"
    }
  )

  depends_on = [aws_security_group.bastion]
}
