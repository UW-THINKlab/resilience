terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
    }
  }
}

data "aws_region" "this" {}

data "aws_default_tags" "this" {}

data "aws_caller_identity" "this" {}

data "aws_iam_group" "this" {
  group_name = var.ops_group_name
}


locals {
    roles_to_create = {
        "scaling-role" = {
            policy_statements = [
                {
                    Effect = "Allow",
                    Action = [
                        "autoscaling:SetDesiredCapacity"
                    ],
                    Resource = var.autoscaling_group_arn
                },
                {
                    Effect = "Allow",
                    Action = [
                        "autoscaling:DescribeAutoScalingGroups"
                    ],
                    Resource = "*"
                }
            ]
        },
        "server-access-role" = {
            policy_statements = [
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
        }
    }
}

resource "aws_iam_role" "ops_roles" {
    for_each = local.roles_to_create
    name = "${var.resource_prefix}-${each.key}"
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
        name = "${var.resource_prefix}_${each.key}_policy"
        policy = jsonencode({
            Version = "2012-10-17",
            Statement = each.value.policy_statements
        })
    }

    # dynamic "inline_policy" {
    #     for_each = each.value.policy_statements
    #     content {
    #         name = "${var.resource_prefix}_${each.key}_policy"
    #         policy = jsonencode({
    #             Version = "2012-10-17",
    #             Statement = inline_policy.value
    #         })
    #     }
    # }
}


moved {
    from = aws_iam_role.scaling
    to = aws_iam_role.ops_roles["scaling-role"]
}

moved {
    from = aws_iam_role.access
    to = aws_iam_role.ops_roles["server-access-role"]
}

// Allow the group to assume each role defined here

resource "aws_iam_group_policy" "assume_ops_roles" {
    for_each = aws_iam_role.ops_roles
    name = "${var.resource_prefix}-assume-${each.key}-policy"
    group = var.ops_group_name

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = "sts:AssumeRole",
                Resource = each.value.arn
            }
        ]
    })
}

