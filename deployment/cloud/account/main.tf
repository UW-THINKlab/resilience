terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  // Tags all resources created from this provider with {"Project": <project name input>, "Neighborhood": <neighborhood input>}
  // as well as any additional tags provided
  default_tags {
    tags = merge(
      var.additional_tags
    )
  }
}

import {
    to = aws_iam_role.deploy
    id = "${var.resource_prefix}-deploy"
}

resource "aws_iam_role" "deploy" {
  name = "${var.resource_prefix}-deploy"
  description = "Role used to deploy infrastructure for the Support Sphere app, part of the Post-Disaster communications project."
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorFullAccess",
  ]
}

# user group


# no trust user


