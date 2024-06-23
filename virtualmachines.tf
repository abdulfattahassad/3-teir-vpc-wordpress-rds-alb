#data "template_file" "vm_script" {
#  template = file("webserverscript.sh")
# t}

data "aws_ami" "ubuntu" {
    
 filter {
    name = "name"
    values = ["al2023-ami-2023*"]

 } 
  
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

 filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  most_recent = true
    
}



resource "aws_instance" "web" {
 count = 3
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  user_data                   = file("${path.module}/wordpressupdate.sh")
  subnet_id =  element( (aws_subnet.private_subnets.*.id), count.index )
  security_groups = [aws_security_group.ALB_TO_Backend_VM.id]
  key_name = "key_pair"
  #   you can  use  EOF/EOF   OR   file(${path.module/xxx})  OR  filebase64()  
  # There are two script  ONE for Wordpress to connect with RDS  OR nomal html script file
  #user_data = <<-EOF
  #  #!/bin/bash
  #  sudo yum install httpd php php-mysqlnd php-json wget -y
  # sudo wget https://wordpress.org/latest.tar.gz
  #  sudo tar -xzvf latest.tar.gz
  #  sudo mv wordpress/* /var/www/html/
  #  sudo chown -R apache.apache /var/www/html
  #  sudo setenforce 0
  #  sudo systemctl start httpd
  #EOF
  #user_data = filebase64(var.userdata_file)
  tags = {
   Name = "Backend_VM - ${count.index} "
  }

  

}


resource "aws_security_group" "ALB_TO_Backend_VM" {
  name        = "ALB_TO_Backend_VM"
  description = "ALB_TO_Backend_VM"
  vpc_id      = aws_vpc.main.id


   dynamic "ingress" {
   for_each = var.SL-Names
   content {
    from_port =       ingress.value
    to_port          = ingress.value
    protocol         = "tcp"
    security_groups = [aws_security_group.ALB-SG.id  ]
      }
   
  }

   
      
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "ALB-TO-Backend-SG"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "key_pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeXNrgijj3PqE+OCLw2g/BoZIMUgpFpiyn+o25Kzk3xxvSW21BJurfUa1ac+Ckwgh7qNyIWDJVwHBxAyyf38elnOrpnOuD3fmSj0LEhgQ4AejpU34HgzIHW9Keq5foTEmfGlNtsW6LrS1OFHQSZfJO8K9l4TOsOp4fMp+a1y8EltJ5PE4stusH/4SLJqkY5UPLOXCYpej2SYNOdvEVdfJrcuLtUaqKq5dVgfa2+5LGJvkMer3FXtVnVfeeOFyP77jAzPDmSs6ap+vH44S1AVWMUcuVJ90x2Zd+2lnO3gJn3LtkyWejun9XndG7Ny4pB0ylNpD80SGEBWyQEKiD6GVb user@DESKTOP-LV7BT04"

}