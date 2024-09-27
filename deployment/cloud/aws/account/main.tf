terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
    }
  }

  backend "s3" {
    bucket = "${var.account_resource_prefix}-${var.account_id}-opentofu-state"
    key = "account/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"

  // Tags all resources created from this provider with {"Project": <project name input>, "Neighborhood": <neighborhood input>}
  // as well as any additional tags provided
  default_tags {
    tags = merge(
      var.account_additional_tags
    )
  }
}

# s3 tf state bucket

resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.account_resource_prefix}-${var.account_id}-opentofu-state"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.tf_state.bucket

  versioning_configuration {
    status = "Enabled"
  }
  
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.tf_state.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# deploy role
resource "aws_iam_role" "deploy" {
  name = "${var.account_resource_prefix}-deploy"
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

resource "aws_iam_role_policy" "deploy_bucket_access" {
  name = "${var.account_resource_prefix}_access_state_from_s3_new"
  role = aws_iam_role.deploy.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ],
        Resource = [
          "${aws_s3_bucket.tf_state.arn}/*",
          aws_s3_bucket.tf_state.arn,
        ],
      },
    ],
  })
}

resource "aws_iam_role_policy" "kms_key_access" {
  name = "${var.account_resource_prefix}_kms_key_admin"
  role = aws_iam_role.deploy.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:TagResource",
          "kms:UntagResource",
          "kms:UpdateKeyDescription",
          "kms:CreateKey",
          "kms:CreateAlias",
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy" "disallow_deploy_role_iam_user_operations" {
  name = "${var.account_resource_prefix}_disallow_deploy_role_iam_user_operations"
  role = aws_iam_role.deploy.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:UpdateUser",
          "iam:CreateLoginProfile",
          "iam:DeleteLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:UpdateAccessKey",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:PutUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:UpdateUserPolicy",
        ],
        Resource = "*",
      }
    ]
  })
}

# user group
resource "aws_iam_group" "this" {
  # TODO: decide if we want to use the account_resource_prefix here
  name = var.ops_group_name
}

resource "aws_iam_group_policy" "assume_deploy" {
  name = "assume-deploy-role"
  group = aws_iam_group.this.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = aws_iam_role.deploy.arn,
      },
    ],
  })
}

resource "aws_iam_group_policy_attachment" "readonly" {
  group = aws_iam_group.this.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
