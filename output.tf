output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "subnet_us-east-1a_id" {
  value = aws_vpc.subnet["us-east-1a"].id
}

output "subnet_us-east-1b_id" {
  value = aws_vpc.subnet["us-east-1b"].id
}

output "subnet_us-east-1c_id" {
  value = aws_vpc.subnet["us-east-1c"].id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "route_table_id" {
  value = aws_route_table.route_table.id
}