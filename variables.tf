variable "aws_profile" {
  type        = string
  description = "AWS Profile"
}

variable "vpc_name" {
  type        = string
  description = "VPC NAME"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR Block"
}

variable "subnet_name_p1" {
  type        = string
  description = "FIRST PART OF SUBNET NAME"
}

variable "igw_name" {
  type        = string
  description = "INTERNET GATEWAY NAME"
}

variable "route_table_name" {
  type        = string
  description = "ROUTE TABLE NAME"
}

variable "internet_cidr_block_ipv4" {
  type        = string
  description = "CIDR BLOCK FOR WORLD WIDE WEB IPV4"
}

variable "internet_cidr_block_ipv6" {
  type        = string
  description = "CIDR BLOCK FOR WORLD WIDE WEB IPV6"
}

variable "subnet_cidr_az_map" {
  type        = map(any)
  description = "Mapping availability to zone to subnet cidrs"
}

variable "app_security_group_ports" {
  type        = list(number)
  description = "List of Application Security Group Ports"
}

variable "rds_subnet_zone1" {
  type        = string
  description = "Subnet zone 1 to deploy rds"
}

variable "rds_subnet_zone2" {
  type        = string
  description = "Subnet zone 2 to deploy rds"
}

variable "database_username" {
  type        = string
  description = "Database Url"
}

variable "database_password" {
  type        = string
  description = "Subnet zone 2 to deploy rds"
}

variable "s3_bucket_name" {
  type        = string
  description = "Subnet zone 2 to deploy rds"
}

variable "db_port" {
  type        = number
  description = "Database port"
}

variable "db_host_str_p1" {
  type        = string
  description = "Database host string part 1"
}

variable "db_name" {
  type        = string
  description = "Database Name"
}