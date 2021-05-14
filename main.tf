#----------------------------------------------------
# Provision:
#  - VPC
#  - Internet Gateway
#  - Public subnets
#  - Private Subnets
#  - NAT Gateways in Public Subnets for Private Subnets
#
# Made by Ruslan Bryl. Spring 2021
#-----------------------------------------------------
provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {}

data "aws_ami" "latest_ubuntu_linux" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["*ubuntu-*-amd64-server-*"]
  }
}


#
#=====================SSH Keys===============================
variable "ssh_key" {
  default = "~/.ssh/id_rsa.pub"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.ssh_key)
}
#====================DataBase================================
resource "aws_instance" "db_server" {
  ami                    = data.aws_ami.latest_ubuntu_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mysql.id]
  subnet_id              = aws_subnet.private1.id
  key_name               = aws_key_pair.deployer.key_name
  tags = {
    Name  = "DataBase Server for WordPress"
    Owner = "Ruslan Bryl"
  }
  lifecycle {
    create_before_destroy = true
  }
}

#====================WebServer===============================

resource "aws_launch_configuration" "web" {
  name_prefix     = "WebServer-Highly-Available-LC-"
  image_id        = data.aws_ami.latest_ubuntu_linux.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.web.id]
  key_name        = aws_key_pair.deployer.key_name
  user_data       = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  #  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
  load_balancers      = [aws_elb.web.name]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "web" {
  name = "WebServer-HA-ELB"
  #availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  subnets         = [aws_subnet.public1.id, aws_subnet.public2.id]
  security_groups = [aws_security_group.web.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-HA-ELB"
  }
}
