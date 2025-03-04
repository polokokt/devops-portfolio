resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound trafficc to the instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-InternetGateway"
  }
}

resource "aws_launch_template" "web_template" {
  name          = "web-launch-template"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = "my-key-name"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_http_ssh.id]
    subnet_id                   = aws_subnet.main.id
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Terraform-ASG-Instance"
    }
  }
}

# Configure Auto Scalling Group
resource "aws_autoscaling_group" "tf_web_asg" {
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.main.id, aws_subnet.secondary.id]
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

}

# VPC definition
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Terraform-PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.main.id # Make sure this is a public subnet
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_association_secondary" {
  subnet_id      = aws_subnet.secondary.id
  route_table_id = aws_route_table.public_rt.id
}


# Subnets definition within the VPC
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-subnet"
  }
}

resource "aws_subnet" "secondary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "SecondarySubnet"
  }
}

#Configure Auto Load Balancer

resource "aws_alb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [aws_subnet.main.id, aws_subnet.secondary.id]
  tags = {
    Name = "Terraform-ALB"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.web_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.tf_web_asg.id
  lb_target_group_arn    = aws_lb_target_group.web_tg.arn
}