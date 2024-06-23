resource "aws_db_subnet_group" "rds_db_subnet_group" {
  count = var.database_subnets_number
  
  name       = "rdsrdsrds-subnet-group${count.index}"
  subnet_ids              = coalescelist (aws_subnet.database_subnets.*.id)


  
}


resource "aws_security_group" "WebServer_TO_RDS" {
  description = "ALB_TO_Backend_VM"
  vpc_id      = aws_vpc.main.id


   ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.ALB_TO_Backend_VM.id  ]
    }
   
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "Webserver_To_RDS"
  }

  
}

resource "aws_db_instance" "default" {
  count = var.database_subnets_number

  allocated_storage    = 10
  db_name              = "demodb01"
  engine               = "mysql"
  # engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "${var.dbadmin}"
  password             = "${var.dbpassword}"
  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.WebServer_TO_RDS.id]
  db_subnet_group_name      = element (aws_db_subnet_group.rds_db_subnet_group.*.id,count.index)
  skip_final_snapshot  = true
  backup_retention_period = 0
  apply_immediately = true
  multi_az = true


  ##https://stackoverflow.com/questions/50930470/terraform-error-rds-cluster-finalsnapshotidentifier-is-required-when-a-final-s##
}


