terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
    }
  }
}

data "aws_region" "current" {}

data "aws_default_tags" "default_tags" {}

// vpc

resource "aws_vpc" "support_sphere_vpc" {
  cidr_block = "10.0.0.0/16"
  
}

resource "aws_subnet" "support_sphere_subnet" {
  vpc_id = aws_vpc.support_sphere_vpc.id
  cidr_block = "10.0.0.0/16"
  availability_zone = "${data.aws_region.current.name}b"
}

// security group
resource "aws_security_group" "support_sphere_sg" {
  name = "support-sphere-sg"
  description = "Support Sphere Security Group"
  vpc_id = aws_vpc.support_sphere_vpc.id
}

resource "aws_security_group_rule" "support_sphere_sg_ssh_ingress" {
  security_group_id = aws_security_group.support_sphere_sg.id
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "support_sphere_sg_ssh_egress" {
  security_group_id = aws_security_group.support_sphere_sg.id
  type = "egress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "support_sphere_sg_http_ingress" {
  security_group_id = aws_security_group.support_sphere_sg.id
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

// instance role

resource "aws_iam_role" "support_sphere_instance_role" {
  name = "support-sphere-instance-role"
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
    name = "support_sphere_instance_policy"
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
          condition = {
            StringEquals = {
              "aws:ResourceTag/Project" = data.aws_default_tags.default_tags.tags.Project
            }
          }
        }
      ]
    })
  }
}


// elastic ip
// we can associate this with the instance in the userdata script
resource "aws_eip" "support_sphere_eip" {
  domain = "vpc"
}


// launch template -- userdata tbd for now

resource "aws_launch_template" "support_sphere_launch_template" {
  name = "support-sphere-launch-template"
  // https://documentation.ubuntu.com/aws/en/latest/aws-how-to/instances/find-ubuntu-images/#finding-images-with-ssm
  image_id = "resolve:ssm:/aws/service/canonical/ubuntu/server/jammy/stable/current/amd64/hvm/ebs-gp2/ami-id"
  instance_type = "r5.large"
  key_name = ""
  security_group_names = []
  user_data = ""

  update_default_version = true
}

// asg

resource "aws_autoscaling_group" "support_sphere_asg" {
  name = "support-sphere-asg"
  launch_template {
    id = aws_launch_template.support_sphere_launch_template.id
    version = "$Latest"
  }
  min_size = 0
  max_size = 1
  desired_capacity = 0
  vpc_zone_identifier = [aws_subnet.support_sphere_subnet.id]

  dynamic "tag" {
    for_each = data.aws_default_tags.default_tags.tags
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

