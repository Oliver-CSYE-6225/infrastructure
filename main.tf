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
  for_each = local.subnet_association_cider

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "application" {
  name        = var.app_security_group_name
  description = var.app_security_group_desc
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = var.app_security_group_description
    from_port        = 443
    to_port          = 443
    protocol         = var.protocol_tcp
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]

  }

  ingress {
    description      = var.app_security_group_description
    from_port        = 22
    to_port          = 22
    protocol         = var.protocol_tcp
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

  ingress {
    description      = var.app_security_group_description
    from_port        = 80
    to_port          = 80
    protocol         = var.protocol_tcp
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

  ingress {
    description      = var.app_security_group_description
    from_port        = 8080
    to_port          = 8080
    protocol         = var.protocol_tcp
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

}

resource "aws_security_group" "database" {
  depends_on  = [aws_security_group.application]
  name        = var.db_security_group_name
  description = var.db_security_group_desc
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = var.db_security_group_description
    from_port       = 5432
    to_port         = 5432
    protocol        = var.protocol_tcp
    security_groups = [aws_security_group.application.id]
  }
}

// resource "aws_kms_key" "kms_encryption_key" {
//   description             = "This key is used to encrypt bucket objects"
//   deletion_window_in_days = 10
// }
resource "random_string" "prefix" {
  upper   = false
  lower   = true
  special = false
  length  = 3
}

resource "aws_s3_bucket" "s3_bucket" {
  // depends_on = [aws_kms_key.kms_encryption_key]

  bucket        = format("%s%s%s", random_string.prefix.result, ".", var.s3_bucket_suffix) 
  acl           = var.s3_bucket_permission
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.default_encrypt_algo_s3
      }
    }
  }

  lifecycle_rule {
    enabled = true
    transition {
      days          = var.s3_lifecycle_transition_days
      storage_class = var.s3_lifecycle_storage_class
    }
  }
}

resource "aws_db_parameter_group" "rds_pg" {
  name   = var.db_pm_group_name
  family = var.db_pm_group_family
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.subnet[var.rds_subnet_zone3].id, aws_subnet.subnet[var.rds_subnet_zone4].id]

  // tags = {
  //   Name = "AWS RDS subnet group"
  // }
}

resource "aws_db_instance" "csye_rds" {
  depends_on             = [aws_db_subnet_group.rds_subnet_group]
  engine                 = var.db_instance_engine
  engine_version         = var.db_instance_engine_version
  instance_class         = var.db_instance_class
  multi_az               = false
  name                   = var.database_name
  username               = var.database_username
  password               = var.database_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  identifier             = var.database_name
  publicly_accessible    = false
  allocated_storage      = var.db_allocated_storage
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = var.db_pm_group_name

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
  ami                     = var.ami_id
  subnet_id               = aws_subnet.subnet[var.rds_subnet_zone1].id
  instance_type           = var.ec2_instance_type
  disable_api_termination = false
  vpc_security_group_ids  = [aws_security_group.application.id]
  root_block_device {
    delete_on_termination = true
    volume_type           = var.ebs_block_type
    volume_size           = var.ebs_volume_size
  }
  // JAVA_OPTS="\$JAVA_OPTS -Dspring-boot.run.arguments=--spring.datasource.url=${aws_db_instance.csye_rds.address}:,--spring.datasource.username=${var.database_username},--spring.datasource.password=${var.database_password},--spring.bucket_name=${aws_s3_bucket.s3_bucket.bucket_domain_name}"

  user_data = <<EOF
#!/bin/bash

####################################################
# TOMCAT SHOULD BE INSTALLED WHEN BUILDING THE AMI #
####################################################
echo "hello"
echo "db_url=${var.db_host_str_p1}${aws_db_instance.csye_rds.address}:${var.db_port}/${var.database_name}" >> /etc/environment
echo "username=${var.database_username}" >> /etc/environment
echo "password=${var.database_password}" >> /etc/environment
echo "s3_bucket_name=${aws_s3_bucket.s3_bucket.id}" >> /etc/environment
EOF

  key_name             = var.ec2_key_name
  iam_instance_profile = aws_iam_instance_profile.s3_instance_profile.name

}

resource "aws_iam_policy" "WebAppS3" {
  name        = var.s3_policy_name
  description = var.s3_policy_description

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
        Resource = [
                aws_s3_bucket.s3_bucket.arn,
                format("%s%s", aws_s3_bucket.s3_bucket.arn, "/*")
            ]
      }
    ]
  })
}

resource "aws_iam_role" "s3_access" {
  depends_on          = [aws_iam_policy.WebAppS3]
  name                = var.iam_role_s3_name
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
  name       = var.iam_instance_profile_name
  role       = aws_iam_role.s3_access.name
}