# data "aws_availability_zones" "available" {
#   state = "available"
# }

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
  
}
#Define internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}
# Define the route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id
}
# Associate the public subnet with the internet gateway
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}


# Define the route to the internet gateway
resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
##### DEFINE SUBNETS #########@#
#1. Public Subnet
resource "aws_subnet" "public_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-public-subnet-${count.index}"
  }
}
#2. Private Subnet
resource "aws_subnet" "private_subnet" {
  count = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index+2) //adjust index to avoid conflicts
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "${local.name}-private-subnet-${count.index}"
  }
}
# Create Nat GateWay
resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.availability_zones)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public_subnet[count.index].id
}

resource "aws_eip" "nat_eip" {
  count = length(var.availability_zones)
  domain = "vpc"
  tags = {
    Name = "${local.name}-nat-eip-${count.index}"
  }
}
resource "aws_route_table" "private_route_table" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
    tags = {
    Name = "${local.name}-private-route-table"
  }
}
resource "aws_route_table_association" "private_route_association" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}


####### DB SUBNET
# resource "aws_subnet" "private_db_subnet" {
#   count = length(var.availability_zones)
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index+3) //adjust index to avoid conflicts
#   availability_zone = element(var.availability_zones, count.index)
#   tags = {
#     Name = "${local.name}-private-db-subnet-${count.index}"
#   }
# }