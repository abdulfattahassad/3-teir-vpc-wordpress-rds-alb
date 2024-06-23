resource "aws_instance" "bastion" {
  count = var.public_subnets_number
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "key_pair"
  subnet_id     = element( (aws_subnet.public_subnets.*.id), count.index )
  tags = {
    Name = "bastiona ${count.index}"
  }

  security_groups = [aws_security_group.ALB-SG.id  ]

  depends_on = [ aws_key_pair.key_pair ]
}
