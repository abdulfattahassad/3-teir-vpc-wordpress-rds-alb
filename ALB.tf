



resource "aws_lb" "external_ALB" {
 
  name               = "ExternalALB"
  
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB-SG.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id ]

   #data.aws_subnet.alb_public_subnet.ids

  #enable_deletion_protection = false

  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.id
  #3  prefix  = "extenal ALB"
  #  enabled = true
  

#  tags = {
 #   Environment = "External ALB  production"
  #}

}






############ Security Group for  ALB  #####



resource "aws_security_group" "ALB-SG" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id


  dynamic "ingress" {
   for_each = var.SL-Names
   content {
    from_port =       ingress.value
    to_port          = ingress.value
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
      }
   
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "ALB-SG"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.external_ALB.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "alb_target_group_attachement" {
  count = 3
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = element(aws_instance.web.*.id, count.index)
  port             = 80
}


resource "aws_lb_listener_rule" "alb_listener_rules" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

   condition {
    host_header {
      values = ["ExternalALB.*"]
    }
  }
}