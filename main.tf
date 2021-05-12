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


terraform {
  backend "s3" {
    bucket = "rus-bryl-wpproject-state"
    key    = "wp/network/terraform.tfstate"
    region = "eu-central-1"
  }
}


data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "rus-bryl-wpproject-state"
    key    = "wp/network/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "latest_ubuntu_linux" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["*ubuntu-*-amd64-server-*"]
  }
}

#=================================================================

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.latest_ubuntu_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  user_data              = file("user_data.sh")
  tags = {
    Name = "WebServer"
  }
}





output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}
