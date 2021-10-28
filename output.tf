output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = {
    for k, v in aws_subnet.subnet : k => v.id
  }
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "route_table_id" {
  value = aws_route_table.route_table.id
}

output "s3_domain_name" {
  value = aws_s3_bucket.s3_bucket.bucket_domain_name
}