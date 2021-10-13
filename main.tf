locals {
  subnet_az_cider = {
    "us-east-1a" = "10.0.2.0/24",
    "us-east-1b" = "10.0.3.0/24",
    "us-east-1c" = "10.0.4.0/24",

  }
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet" {

  for_each = local.subnet_az_cider

  depends_on              = [aws_vpc.vpc]
  cidr_block              = each.value
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = format("%s%s%s", var.subnet_name_p1, "_", each.key)
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "route_table" {
  depends_on = [aws_internet_gateway.igw]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "sub_ass" {
  for_each = local.subnet_az_cider

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.route_table.id
}