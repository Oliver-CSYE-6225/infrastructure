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


resource "aws_security_group" "WebAppSecurityGroup" {
  depends_on  = [aws_security_group.application]
  name        = "WebAppSecurityGroup"
  description = "WebAppSecurityGroup"
  vpc_id      = aws_vpc.vpc.id
// ingress {
//     description      = var.app_security_group_description
//     from_port        = 443
//     to_port          = 443
//     protocol         = var.protocol_tcp
//     cidr_blocks      = [var.internet_cidr_block_ipv4]
//     ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]

//   }

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
    security_groups = [aws_security_group.application.id]
    // cidr_blocks      = [var.internet_cidr_block_ipv4]
    // ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

  ingress {
    description      = var.app_security_group_description
    from_port        = 8080
    to_port          = 8080
    protocol         = var.protocol_tcp
    security_groups = [aws_security_group.application.id]
    // cidr_blocks      = [var.internet_cidr_block_ipv4]
    // ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.internet_cidr_block_ipv4]
    ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  }
  //   ingress {
  //   description      = var.app_security_group_description
  //   from_port       = 80
  //   to_port         = 80
  //   protocol        = var.protocol_tcp
  //   security_groups = [aws_security_group.application.id]
  //   }
  // // ingress {
  // //   description      = var.app_security_group_description
  // //   from_port        = 443
  // //   to_port          = 443
  // //   protocol         = var.protocol_tcp
  // //   cidr_blocks      = [var.internet_cidr_block_ipv4]
  // //   ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]

  // // }

  // // ingress {
  // //   description      = var.app_security_group_description
  // //   from_port        = 22
  // //   to_port          = 22
  // //   protocol         = var.protocol_tcp
  // //   cidr_blocks      = [var.internet_cidr_block_ipv4]
  // //   ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  // // }

  // // ingress {
  // //   description      = var.app_security_group_description
  // //   from_port        = 80
  // //   to_port          = 80
  // //   protocol         = var.protocol_tcp
  // //   cidr_blocks      = [var.internet_cidr_block_ipv4]
  // //   ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  // // }

  // ingress {
  //   description      = var.app_security_group_description
  //   from_port       = 8080
  //   to_port         = 8080
  //   protocol        = var.protocol_tcp
  //   security_groups = [aws_security_group.application.id]
  // }

  // egress {
  //   from_port        = 0
  //   to_port          = 0
  //   protocol         = "-1"
  //   cidr_blocks      = [var.internet_cidr_block_ipv4]
  //   ipv6_cidr_blocks = [var.internet_cidr_block_ipv6]
  // }

}

resource "aws_security_group" "database" {
  depends_on  = [aws_security_group.WebAppSecurityGroup]
  name        = var.db_security_group_name
  description = var.db_security_group_desc
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = var.db_security_group_description
    from_port       = 5432
    to_port         = 5432
    protocol        = var.protocol_tcp
    security_groups = [aws_security_group.WebAppSecurityGroup.id]
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
}


resource "aws_db_parameter_group" "rds_pg" {
  name   = var.db_pm_group_name
  family = var.db_pm_group_family
  parameter {
    name  = "rds.force_ssl"
    value = 1
  }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.subnet[var.rds_subnet_zone2].id, aws_subnet.subnet[var.rds_subnet_zone4].id]

  // tags = {
  //   Name = "AWS RDS subnet group"
  // }
}

resource "aws_kms_key" "kms_key_rds" {
  description             = "Customer managed key for RDS"
  deletion_window_in_days = 10
}

// resource "aws_kms_key" "kms_key_rds_replica" {
//   description             = "Customer managed key for RDS"
//   deletion_window_in_days = 10
// }

resource "aws_db_instance" "csye_rds" {
  depends_on             = [aws_db_parameter_group.rds_pg, aws_db_subnet_group.rds_subnet_group]
  engine                 = var.db_instance_engine
  engine_version         = var.db_instance_engine_version
  instance_class         = var.db_instance_class
  multi_az               = false
  name                   = var.database_name
  username               = var.database_username
  password               = var.database_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
    availability_zone = "us-east-1c"
  identifier             = var.database_name
  publicly_accessible    = false
  allocated_storage      = var.db_allocated_storage
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = var.db_pm_group_name
  backup_retention_period = 5
  storage_encrypted = true
  kms_key_id = aws_kms_key.kms_key_rds.arn

}

resource "aws_db_instance" "csye_rds_read_replica" {
  depends_on             = [aws_db_instance.csye_rds,aws_db_parameter_group.rds_pg, aws_db_subnet_group.rds_subnet_group]
  engine                 = var.db_instance_engine
  engine_version         = var.db_instance_engine_version
  instance_class         = var.db_instance_class
  multi_az               = false
  // name                   = "csye6225"
  // username               = var.database_username
  // password               = var.database_password
  // db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  availability_zone = "us-east-1d"
  identifier             = "csye6225replica"
  publicly_accessible    = false
  // allocated_storage      = var.db_allocated_storage
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = var.db_pm_group_name
  replicate_source_db = aws_db_instance.csye_rds.id
  storage_encrypted = true
  kms_key_id = aws_kms_key.kms_key_rds.arn
  // backup_retention_period = 1


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
data "aws_ami" "csye_ami" {
  most_recent = true
  owners      = [var.dev_acc_num]

  filter {
    name   = "name"
    values = ["csye6225-*"]
  }
}

// resource "aws_instance" "ec2_instance" {
//   depends_on              = [aws_db_instance.csye_rds, aws_iam_instance_profile.s3_instance_profile]
//   ami                     = data.aws_ami.csye_ami.id
//   subnet_id               = aws_subnet.subnet[var.rds_subnet_zone1].id
//   instance_type           = var.ec2_instance_type
//   disable_api_termination = false
//   vpc_security_group_ids  = [aws_security_group.application.id]
//   root_block_device {
//     delete_on_termination = true
//     volume_type           = var.ebs_block_type
//     volume_size           = var.ebs_volume_size
//   }
//   // JAVA_OPTS="\$JAVA_OPTS -Dspring-boot.run.arguments=--spring.datasource.url=${aws_db_instance.csye_rds.address}:,--spring.datasource.username=${var.database_username},--spring.datasource.password=${var.database_password},--spring.bucket_name=${aws_s3_bucket.s3_bucket.bucket_domain_name}"

//   user_data = <<EOF
// #!/bin/bash

// ####################################################
// # TOMCAT SHOULD BE INSTALLED WHEN BUILDING THE AMI #
// ####################################################
// echo "hello"
// echo "db_url=${var.db_host_str_p1}${aws_db_instance.csye_rds.address}:${var.db_port}/${var.database_name}" >> /etc/environment
// echo "username=${var.database_username}" >> /etc/environment
// echo "password=${var.database_password}" >> /etc/environment
// echo "s3_bucket_name=${aws_s3_bucket.s3_bucket.id}" >> /etc/environment
// EOF

//   key_name             = var.ec2_key_name
//   iam_instance_profile = aws_iam_instance_profile.s3_instance_profile.name

//   tags = {
//     Name                = "csye-6225-1"
//     instance_identifier = "webapp_deploy"
//   }
// }

resource "aws_sns_topic" "verify-user" {
  name = "verify-user"
}

// resource "aws_iam_role" "autoscale_role" {
//   name = "iam-role-for-grant"

//   assume_role_policy = <<EOF
// {
//   "Version": "2012-10-17",
//   "Statement": [
//     {
//       "Action": "sts:AssumeRole",
//       "Principal": {
//         "Service": "autoscaling.amazonaws.com"
//       },
//       "Effect": "Allow",
//       "Sid": ""
//     }
//   ]
// }
// EOF
// }


//EBS key
data "aws_iam_policy_document" "ebs_key_policy" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
        "kms:Encrypt",
       "kms:Decrypt",
       "kms:ReEncrypt*",
       "kms:GenerateDataKey*",
       "kms:DescribeKey"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::546679085257:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
        "arn:aws:iam::546679085257:user/prod_admin"
      ]
    }

    resources = [
      "*",
    ]
  }

  statement {
    sid = "2"
    effect = "Allow"
    actions = [
                "kms:Create*",
                      "kms:Describe*",
                      "kms:Enable*",
                      "kms:List*",
                      "kms:Put*",
                      "kms:Update*",
                      "kms:Revoke*",
                      "kms:Disable*",
                      "kms:Get*",
                      "kms:Delete*",
                      "kms:ScheduleKeyDeletion",
                      "kms:CancelKeyDeletion"    ]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::546679085257:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
        "arn:aws:iam::546679085257:user/prod_admin",
        "arn:aws:iam::546679085257:root"
      ]
    }

    resources = [
      "*",
    ]
    // condition {
    //   test     = "bool"
    //   variable = "s3:prefix"

    //   values = [
    //     "",
    //     "home/",
    //     "home/&{aws:username}/",
    //   ]
    // }
  }
}

// resource "aws_iam_policy" "encrypt-ec2-policy" {
//   name   = "encrypt-ec2-policy"
//   path   = "/"
//   policy = data.aws_iam_policy_document.ebs_key_policy.json
// }

resource "aws_kms_key" "kms_key_ebs" {
  description             = "Customer managed key for EBS Volume"
  deletion_window_in_days = 10
  policy = data.aws_iam_policy_document.ebs_key_policy.json
  
  // jsonencode({
  //         "Version": "2012-10-17",
  //         "Id": "key-default-1",
  //         "Statement": [
  //             {
  //                 "Sid": "Allow administration of the key",
  //                 "Effect": "Allow",
  //                 "Principal": { "AWS": "arn:aws:iam::546679085257:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling" },
  //                 "Action": [
  //                     "kms:Create*",
  //                     "kms:Describe*",
  //                     "kms:Enable*",
  //                     "kms:List*",
  //                     "kms:Put*",
  //                     "kms:Update*",
  //                     "kms:Revoke*",
  //                     "kms:Disable*",
  //                     "kms:Get*",
  //                     "kms:Delete*",
  //                     "kms:ScheduleKeyDeletion",
  //                     "kms:CancelKeyDeletion"
  //                 ],
  //                 "Resource": "*"
  //             },
  //             {
  //                 "Sid": "Allow use of the key",
  //                 "Effect": "Allow",
  //                 "Principal": { "AWS": "arn:aws:iam::546679085257:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling" },
  //                 "Action": [
  //                     "kms:Encrypt",
  //                     "kms:Decrypt",
  //                     "kms:ReEncrypt",
  //                     "kms:GenerateDataKey*",
  //                     "kms:DescribeKey"
  //                 ], 
  //                 "Resource": "*"
  //             }
  //         ]
  //     })
}

resource "aws_ebs_default_kms_key" "default_ebs_key" {
  key_arn = aws_kms_key.kms_key_ebs.arn
}



// resource "aws_kms_grant" "autoscale_role_grant" {
//   name              = "my-grant"
//   key_id            = aws_kms_key.kms_key_ebs.key_id
//   grantee_principal = aws_iam_role.autoscale_role.arn
//   operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]

//   // constraints {
//   //   encryption_context_equals = {
//   //     Department = "Finance"
//   //   }
//   // }
// }




// data "aws_iam_policy_document" "kms_use1" {
//   statement {
//     sid = "Allow KMS Use"
//     effect = "Allow"
//     actions = [
//       "kms:Encrypt",
//       "kms:Decrypt",
//       "kms:ReEncrypt*",
//       "kms:GenerateDataKey*",
//       "kms:DescribeKey",
//     ]
//     resources = ["*"]
//   }
// }

// resource "aws_iam_policy" "kms_use1_policy" {
//   name        = "kmsuse1"
//   description = "Policy to allow use of KMS Key"
//   policy      = data.aws_iam_policy_document.kms_use1.json
// }

// resource "aws_iam_role_policy_attachment" "kms1" {
//   role       = aws_iam_service_linked_role.autoscaling.name
//   policy_arn = aws_iam_policy.kms_use1_policy.arn
// }

// data "aws_iam_policy_document" "kms_use2" {
//   statement {
//     sid = "Allow KMS Use"
//     effect = "Allow"
//     actions = [
//             "kms:CreateGrant"
//     ]
//     resources = ["*"]
//   }
// }

// resource "aws_iam_policy" "kms_use2_policy" {
//   name        = "kmsuse2"
//   description = "Policy to allow use of KMS Key 2"
//   policy      = data.aws_iam_policy_document.kms_use2.json
// }

// resource "aws_iam_role_policy_attachment" "kms2" {
//   role       = aws_iam_service_linked_role.autoscaling.name
//   policy_arn = aws_iam_policy.kms_use2_policy.arn
// }

// resource "aws_ebs_encryption_by_default" "example" {
//   enabled = true
// }


resource "aws_launch_configuration" "asg_launch_config" {
  name_prefix   = "asg_launch_config"
  depends_on = [aws_security_group.WebAppSecurityGroup]
  image_id                    = data.aws_ami.csye_ami.id
  instance_type               = "t2.micro"
  key_name                    = var.ec2_key_name
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash

####################################################
# TOMCAT SHOULD BE INSTALLED WHEN BUILDING THE AMI #
####################################################
echo "hello"
echo "db_url=${var.db_host_str_p1}${aws_db_instance.csye_rds.address}:${var.db_port}/${var.database_name}${var.db_host_str_p2}" >> /etc/environment
echo "db_url2=${var.db_host_str_p1}${aws_db_instance.csye_rds_read_replica.address}:${var.db_port}/${var.database_name}${var.db_host_str_p2}" >> /etc/environment
echo "username=${var.database_username}" >> /etc/environment
echo "password=${var.database_password}" >> /etc/environment
echo "s3_bucket_name=${aws_s3_bucket.s3_bucket.id}" >> /etc/environment
echo "sns_topic_arn=${aws_sns_topic.verify-user.arn}" >> /etc/environment
echo "dynamo_endpoint=https://dynamodb.${var.aws_region}.amazonaws.com" >> /etc/environment

EOF
  iam_instance_profile        = aws_iam_instance_profile.s3_instance_profile.name
  // name                        = "asg_launch_config"
  security_groups             = [aws_security_group.WebAppSecurityGroup.id]
  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    encrypted = true
  }
}

resource "aws_autoscaling_group" "webapp_autoscale_group" {
  // availability_zones = ["us-east-1a"]
  name                 = "webapp_autoscale_group"
  default_cooldown     = 60
  launch_configuration = aws_launch_configuration.asg_launch_config.name
  vpc_zone_identifier  = [aws_subnet.subnet[var.rds_subnet_zone1].id]
  //Change needed desired=3, min=3, max=5
  desired_capacity     = 3
  max_size             = 5
  min_size             = 3

  tag {
    key                 = "instance_identifier"
    value               = "webapp_deploy"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "csye-6225-1"
    propagate_at_launch = true
  }

  // warm_pool {
  //   pool_state                  = "Stopped"
  //   min_size                    = 1
  //   max_group_prepared_capacity = 10
  // }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  autoscaling_group_name = aws_autoscaling_group.webapp_autoscale_group.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  // predefined_metric_specification {
  // predefined_metric_type = "CPUUtilization"
  // }
  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    // metric_interval_upper_bound = 2.0
  }
  
  // step_adjustment {
  //   scaling_adjustment = -1
  //   metric_interval_lower_bound = 0
  //   metric_interval_upper_bound = 3
  // }

  // step_adjustment {
  //   scaling_adjustment = 0
  //   metric_interval_lower_bound = 3
  //   metric_interval_upper_bound = 5
  // }

  // scaling_adjustment     = 4
  // adjustment_type        = "ChangeInCapacity"
  // cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  autoscaling_group_name = aws_autoscaling_group.webapp_autoscale_group.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment = -1
    metric_interval_upper_bound = 3
  }

 step_adjustment {
    scaling_adjustment = 0
        metric_interval_lower_bound = 3
  }
  // scaling_adjustment     = 4
  // adjustment_type        = "ChangeInCapacity"
  // cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "CPUUtilization_Breaches_5%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_autoscale_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "CPUUtilization_Below_3%"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "3"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_autoscale_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}


resource "aws_lb_target_group" "ec2-target-group" {
  depends_on = [aws_vpc.vpc]
  name     = "ec2-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  depends_on = [aws_autoscaling_group.webapp_autoscale_group]
  autoscaling_group_name = aws_autoscaling_group.webapp_autoscale_group.id
  alb_target_group_arn = aws_lb_target_group.ec2-target-group.arn
}

resource "aws_lb" "webapp_load_balancer" {
  name      = "webapp-load-balancer"
  // instances = [aws_instance.ec2_instance.id]
  subnets   = [aws_subnet.subnet[var.rds_subnet_zone1].id, aws_subnet.subnet[var.rds_subnet_zone3].id]
  security_groups    = [aws_security_group.application.id]

  // listener {
  //   instance_port     = 80
  //   instance_protocol = "http"
  //   lb_port           = 80
  //   lb_protocol       = "http"
  // }

}

resource "aws_lb_listener" "webapp-load-balancer-listener" {
  load_balancer_arn = aws_lb.webapp_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  // certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  certificate_arn = "arn:aws:acm:us-east-1:546679085257:certificate/a84c8fa9-5c62-458f-bfda-cc4c18338e98"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2-target-group.arn
  }
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
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.s3_bucket.arn,
          format("%s%s", aws_s3_bucket.s3_bucket.arn, "/*")
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "SNS-Publish" {
  name        = "SNS-Publish"
  description = "SNS-Publish"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "SNS:Publish",
        ],
        Effect = "Allow"
        Resource = aws_sns_topic.verify-user.arn
      }
    ]
  })
}


resource "aws_dynamodb_table" "dynamodb-table" {
    depends_on = [aws_iam_policy.WebAppDynamo]

  name           = "Email-Tokens"
  // billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "EmailId"
  // range_key      = "GameTitle"

  attribute {
    name = "EmailId"
    type = "S"
  }

  attribute {
    name = "Token"
    type = "S"
  }

  // attribute {
  //   name = "TopScore"
  //   type = "N"
  // }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  global_secondary_index {
    name               = "EmailTokenIndex"
    hash_key           = "Token"
    // range_key          = "Token"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["EmailId"]
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

resource "aws_iam_policy" "WebAppDynamo" {
  name        = "Web-App-Dynamo"
  description = "Policy to provide ec2 access to Dynamo"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListAndDescribe",
            "Effect": "Allow",
            "Action": [
                "dynamodb:List*",
                "dynamodb:DescribeReservedCapacity*",
                "dynamodb:DescribeLimits",
                "dynamodb:DescribeTimeToLive"
            ],
            "Resource": "*"
        },
        {
            "Sid": "SpecificTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:CreateTable",
                "dynamodb:Delete*",
                "dynamodb:Update*",
                "dynamodb:PutItem"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/Email-Tokens"
        }
    ]
})
}



resource "aws_iam_instance_profile" "s3_instance_profile" {
  depends_on = [aws_iam_role.s3_access]
  name       = var.iam_instance_profile_name
  role       = aws_iam_role.s3_access.name
}


data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  name = "CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "s3_access" {
  depends_on          = [aws_iam_policy.WebAppS3]
  name                = var.iam_role_s3_name
  managed_policy_arns = [aws_iam_policy.WebAppS3.arn, data.aws_iam_policy.CloudWatchAgentServerPolicy.arn, aws_iam_policy.WebAppDynamo.arn, aws_iam_policy.SNS-Publish.arn]
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