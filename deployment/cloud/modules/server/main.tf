terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
      configuration_aliases = [ aws.east ]
    }
  }
}

data "aws_region" "this" {}

data "aws_default_tags" "this" {}

data "aws_caller_identity" "this" {}

// vpc

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.0"

    name = "${var.resource_prefix}-vpc"
    cidr = "10.0.0.0/16"

    azs = ["${data.aws_region.this.name}a", "${data.aws_region.this.name}b", "${data.aws_region.this.name}c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false
    enable_dns_hostnames = true
    enable_dhcp_options  = true
}

data "aws_kms_alias" "us_west_2" {
  name = "alias/${var.resource_prefix}-kms-key-us-west-2"
}

data "aws_kms_alias" "us_east_1" {
  provider = aws.east
  name = "alias/${var.resource_prefix}-kms-key-us-east-1"
}


// instance role

resource "aws_iam_role" "instance" {
  name = "${var.resource_prefix}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "${var.resource_prefix}_instance_policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:AssociateAddress",
            "ec2:DisassociateAddress"
          ],
          Resource = "*",
          Condition = {
            StringEquals = {
              "aws:ResourceTag/Project" = data.aws_default_tags.this.tags.Project
            }
          }
        },
        {
          Effect = "Allow",
          Action = [
            "ec2:DescribeAddresses"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = [
            "kms:Decrypt"
          ],
          Resource = [
            data.aws_kms_alias.us_west_2.target_key_arn,
            data.aws_kms_alias.us_east_1.target_key_arn
          ]
        }
      ]
    })
  }

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}


resource "aws_iam_instance_profile" "this" {
  name = "${var.resource_prefix}-instance-profile"
  role = aws_iam_role.instance.name
}

// security group
resource "aws_security_group" "this" {
  name = "${var.resource_prefix}-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// launch template -- userdata tbd for now

resource "aws_eip" "this" {
  domain = "vpc"
}



resource "aws_launch_template" "this" {
  name = "${var.resource_prefix}-template"
  // https://documentation.ubuntu.com/aws/en/latest/aws-how-to/instances/find-ubuntu-images/#finding-images-with-ssm
  image_id = "resolve:ssm:/aws/service/canonical/ubuntu/server/jammy/stable/current/amd64/hvm/ebs-gp2/ami-id"
  instance_type = var.instance_type
  key_name = ""
  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.volume_size
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.this.id]
  }

  user_data = base64encode(templatefile("${path.module}/userdata", {
    allocationid = aws_eip.this.allocation_id,
    region = data.aws_region.this.name
  }))

  update_default_version = true
}

// asg

resource "aws_autoscaling_group" "this" {
  name = "${var.resource_prefix}-asg"
  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }
  min_size = 0
  max_size = 1
  desired_capacity = 0
  vpc_zone_identifier = [module.vpc.public_subnets[0]]

  dynamic "tag" {
    for_each = data.aws_default_tags.this.tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

// Autoscaling action to shutdown the server every weekday at 1AM UTC (6PM PDT/5PM PST)
resource "aws_autoscaling_schedule" "scale_down" {
  # only create this resource in non-prod environments
  count = var.stage != "prod" ? 1 : 0

  scheduled_action_name = "${var.resource_prefix}-asg-shutdown-after-working-hours"
  min_size = 0
  desired_capacity = 0
  max_size = 1
  recurrence = "0 1 * * MON-FRI"
  autoscaling_group_name = aws_autoscaling_group.this.name
}

// role to scale up and down the server asg
resource "aws_iam_role" "scaling" {
    name = "${var.resource_prefix}-scaling-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })

    inline_policy {
        name = "${var.resource_prefix}_server_run_policy"
        policy = jsonencode({
            Version = "2012-10-17",
            Statement = [
                {
                    Effect = "Allow",
                    Action = [
                        "autoscaling:SetDesiredCapacity"
                    ],
                    Resource = aws_autoscaling_group.this.arn
                },
                {
                    Effect = "Allow",
                    Action = [
                        "autoscaling:DescribeAutoScalingGroups"
                    ],
                    Resource = "*"
                }
            ]
        })
    }
}

resource "aws_iam_role" "access" {
    name = "${var.resource_prefix}-server-access-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })

    inline_policy {
        name = "${var.resource_prefix}_server_access_policy"
        policy = jsonencode({
            Version = "2012-10-17",
            Statement = [
                {
                    Effect = "Allow",
                    Action = [
                        "ssm:StartSession"
                    ],
                    Resource = [
                      "arn:aws:ssm:${data.aws_region.this.name}::document/AWS-StartInteractiveCommand",
                      "arn:aws:ec2:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:instance/*"
                    ]
                },
                {
                    Effect = "Allow",
                    Action = [
                        "ec2:DescribeInstances"
                    ],
                    Resource = "*"
                }
            ]
        })
    }
}