resource "aws_launch_template" "web_sever_as" {
  name                   = "myproject"
  ami                    =  "ami-000ec6c25978d5999"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = "keypair"
  tags = {
    Name = "DevOps"
  }
}

resource "aws_elb" "web_server_lb" {
  name            = "web_server_lb"
  security_groups = [aws_security_group.web_server.id]
  subnet_id       = ["subnet-0ea715128139b6639 ", "subnet-0f02721f3c50a4541"]
  listener {
   instance_port        = 8000
   instance_protocol    = "http"
   lb_port              = 80
   lb_protocol          = "http"
  }
  tags = {
    Name = "terraform-elb"
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  name                    = "web_server_asg"
  min_size                = 1
  max_size                = 3
  desired_capacity        = 2
  health_check_type       = "EC2"
  load_balancers          = [aws_elb.web_server_lb.name]
  availability_zones       = ["us-east-1a","us-east-1b"]
  launch_template {
       id                 = aws_launch_template.web_server_as.id
       version            = "$Latest"
     }
}
