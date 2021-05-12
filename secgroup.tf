resource "aws_security_group" "mysql" {
  name        = "${var.env}-DataBase-SG"
  description = "managed by terrafrom for db servers"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-DataBase-SG"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = ["${aws_security_group.web.id}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name        = "${var.env}-web-SG"
  description = "This is for ${var.env}s web servers security group"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-web-SG"
  }


  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }


  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
