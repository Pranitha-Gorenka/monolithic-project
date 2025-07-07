# Security Group for Web Server (HTTP Access + Optional SSH)
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Allow HTTP and optional SSH access"
  vpc_id      = "04dee8091ad8f0506" # Replace with your actual VPC ID

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional: SSH access only from your IP
  ingress {
    description = "SSH access from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your actual IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template
resource "aws_launch_template" "web_sever_as" {
  name                   = "myproject"
  image_id               = "ami-000ec6c25978d5999"
  instance_type          = "t2.micro"
  key_name               = "keypair" # Replace with your key name

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_server.id]
  }

  tags = {
    Name = "DevOps"
  }
}

# Elastic Load Balancer
resource "aws_elb" "web_server_lb" {
  name            = "web-server-lb"
  security_groups = [aws_security_group.web_server.id]
  subnets         = ["subnet-0ea715128139b6639", "subnet-0f02721f3c50a4541"] # Replace with valid subnet IDs

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    Name = "terraform-elb"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_server_asg" {
  name               = "web-server-asg"
  min_size           = 1
  max_size           = 3
  desired_capacity   = 2
  health_check_type  = "EC2"
  load_balancers     = [aws_elb.web_server_lb.name]
  availability_zones = ["us-east-1a", "us-east-1b"]

  launch_template {
    id      = aws_launch_template.web_sever_as.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-server-instance"
    propagate_at_launch = true
  }
}
