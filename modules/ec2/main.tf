locals {
  prefix = "${var.prefix}"
}

resource "aws_instance" "sample" {
  ami           = "ami-06cce67a5893f85f9"
  instance_type = "t2.micro"
  tags = {
    Name = "${local.prefix}example-ec2"
  }
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data = file("${path.module}/scripts/user_data.sh")
  user_data_replace_on_change = true
}

resource "aws_security_group" "allow_ssh" {
  name = "${local.prefix}allow_ssh"
  vpc_id = data.aws_vpc.default.id
  description = "Allow SSH inbound traffic"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_vpc" "default" {
  default = true
}
