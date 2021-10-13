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