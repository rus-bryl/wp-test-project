#=====================VPCs========================================

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

/*
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}
*/

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-vpc-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-vpc-2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private-vpc-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private-vpc-2"
  }
}

resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-subnetgroup"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
  tags = {
    Name = "MySQL-SubnetGroup"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "wp-net-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "wp-public-default-route"
  }
}

resource "aws_route_table_association" "public1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public1.id
}

resource "aws_route_table_association" "public2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public2.id
}

resource "aws_eip" "eip1" {
  vpc = true
  tags = {
    Name = "wp-net-nat1-ip"
  }
}
resource "aws_eip" "eip2" {
  vpc = true
  tags = {
    Name = "wp-net-nat2-ip"
  }
}

resource "aws_nat_gateway" "nat1" {
  subnet_id     = aws_subnet.public1.id
  allocation_id = aws_eip.eip1.id
  tags = {
    Name = "wp-net-nat1"
  }
}

resource "aws_nat_gateway" "nat2" {
  subnet_id     = aws_subnet.public2.id
  allocation_id = aws_eip.eip2.id
  tags = {
    Name = "wp-net-nat2"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }
  tags = {
    Name = "wp-private1-default-route"
  }
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat2.id
  }
  tags = {
    Name = "wp-private2-default-route"
  }
}

resource "aws_route_table_association" "private1" {
  route_table_id = aws_route_table.private1.id
  subnet_id      = aws_subnet.private1.id
}

resource "aws_route_table_association" "private2" {
  route_table_id = aws_route_table.private2.id
  subnet_id      = aws_subnet.private2.id
}
