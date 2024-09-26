terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
      configuration_aliases = [ aws.east ]
    }
  }
}

data "aws_region" "west" {}

data "aws_region" "east" {
  provider = aws.east
}

# KMS keys for encryption

resource "aws_kms_key" "west" {
  description = "Key in us-west-2 for encrypting and decrypting server config values for the Support Sphere project."
  key_usage = "ENCRYPT_DECRYPT"
}

resource "aws_kms_alias" "west" {
  name = "alias/${var.resource_prefix}-kms-key-${data.aws_region.west.name}"
  target_key_id = aws_kms_key.west.key_id
}

resource "aws_kms_key" "east" {
  provider = aws.east
  description = "Key in us-east-1 for encrypting and decrypting server config values for the Support Sphere project."
  key_usage = "ENCRYPT_DECRYPT"
}

resource "aws_kms_alias" "east" {
  provider = aws.east
  name = "alias/${var.resource_prefix}-kms-key-${data.aws_region.east.name}"
  target_key_id = aws_kms_key.east.key_id
}

# KMS key attachment to group policy

data "aws_iam_group" "this" {
  group_name = var.ops_group_name
}

resource "aws_iam_group_policy" "this" {
  name = "${var.resource_prefix}-kms-key-policy"
  group = var.ops_group_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt"
        ],
        Resource = [
          aws_kms_alias.west.target_key_arn,
          aws_kms_alias.east.target_key_arn
        ]
      }
    ]
  })
}