resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
  enable_dns_support   = true
  enable_dns_hostnames = true
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
    cidr_block = var.internet_cidr_block_ipv4
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

resource "aws_security_group" "application" {
  name        = "application"
  description = "Allow all inbound traffic from the internet to selected ports"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TCP traffic from the internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]

  }

  ingress {
    description      = "TCP traffic from the internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

  ingress {
    description      = "TCP traffic from the internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

  ingress {
    description      = "TCP traffic from the internet"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_security_group" "database" {
  depends_on  = [aws_security_group.application]
  name        = "database"
  description = "Allow all inbound traffic from the internet to selected ports"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "TCP traffic from the internet"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }
}

resource "aws_kms_key" "kms_encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}


resource "aws_s3_bucket" "s3_bucket" {
  depends_on = [aws_kms_key.kms_encryption_key]

  bucket        = var.s3_bucket_name
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
  tags = {
    Name        = "random-string.dev.domain.tld"
    Environment = "Dev"
  }
}

resource "aws_db_parameter_group" "rds_pg" {
  name   = "rds-pg"
  family = "postgres13"

  // parameter {
  //   name  = "character_set_server"
  //   value = "utf8"
  // }

  // parameter {
  //   name  = "character_set_client"
  //   value = "utf8"
  // }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.subnet[var.rds_subnet_zone1].id, aws_subnet.subnet[var.rds_subnet_zone2].id]

  tags = {
    Name = "AWS RDS subnet group"
  }
}

resource "aws_db_instance" "csye_rds" {
  depends_on             = [aws_db_subnet_group.rds_subnet_group]
  engine                 = "postgres"
  engine_version         = "13.3"
  instance_class         = "db.t3.micro"
  multi_az               = false
  name                   = "csye6225"
  username               = var.database_username
  password               = var.database_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  identifier             = "csye6225"
  publicly_accessible    = false
  allocated_storage      = 10
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database.id]
}


// resource "aws_network_interface" "network_interface" {
//   subnet_id       = aws_subnet.subnet[var.rds_subnet_zone1].id
//   private_ips     = ["10.0.0.50"]
//   security_groups = [aws_security_group.web.id]

//   attachment {
//     instance     = aws_instance.test.id
//     device_index = 1
//   }
// }


resource "aws_instance" "ec2_instance" {
  depends_on              = [aws_db_instance.csye_rds, aws_iam_instance_profile.s3_instance_profile]
  ami                     = "ami-0a3fa4762ce0f0840"
  subnet_id               = aws_subnet.subnet[var.rds_subnet_zone1].id
  instance_type           = "t2.micro"
  disable_api_termination = false
  vpc_security_group_ids  = [aws_security_group.application.id]
  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 20
  }
  // JAVA_OPTS="\$JAVA_OPTS -Dspring-boot.run.arguments=--spring.datasource.url=${aws_db_instance.csye_rds.address}:,--spring.datasource.username=${var.database_username},--spring.datasource.password=${var.database_password},--spring.bucket_name=${aws_s3_bucket.s3_bucket.bucket_domain_name}"

  user_data = <<EOF
#!/bin/bash

####################################################
# TOMCAT SHOULD BE INSTALLED WHEN BUILDING THE AMI #
####################################################
echo "hello"
echo "db_url=${var.db_host_str_p1}${aws_db_instance.csye_rds.address}:${var.db_port}/${var.db_name}" >> /etc/environment
echo "username=${var.database_username}" >> /etc/environment
echo "password=${var.database_password}" >> /etc/environment
echo "s3_bucket_name=${aws_s3_bucket.s3_bucket.bucket_domain_name}" >> /etc/environment
EOF

  key_name             = "csye-6225"
  iam_instance_profile = aws_iam_instance_profile.s3_instance_profile.name

}

resource "aws_iam_policy" "WebAppS3" {
  name        = "WebAppS3"
  description = "WebAppS3 policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
           "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
         Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "s3_access" {
  depends_on          = [aws_iam_policy.WebAppS3]
  name                = "EC2-CSYE6225"
  managed_policy_arns = [aws_iam_policy.WebAppS3.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "s3_instance_profile" {
  depends_on = [aws_iam_role.s3_access]
  name       = "s3_instance_profile"
  role       = aws_iam_role.s3_access.name
}

