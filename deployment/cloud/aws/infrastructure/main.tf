terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
    }
  }

  backend "s3" {
    bucket = "${local.account_resource_prefix}-${var.account_id}-opentofu-state"
    key    = "infrastructure/${local.neighborhood_lower}/${var.stage}/terraform.tfstate"
    region = "us-west-2"
  }
}

locals {
  // The resource prefix is a combination of the project name and neighborhood
  // This will be used to name all resources created by this module
  account_resource_prefix = lower(trimspace(replace(var.project_name, " ", "")))
  neighborhood_lower      = lower(trimspace(replace(var.neighborhood, " ", "")))

  resource_prefix = join("-",
    [local.account_resource_prefix,
    local.neighborhood_lower]
  )
}

provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/supportsphere-deploy"
    session_name = "${local.resource_prefix}-infra-deployment"
    external_id  = "${local.resource_prefix}-infra-deployment"
  }

  // Tags all resources created from this provider with {"Project": <project name input>, "Neighborhood": <neighborhood input>}
  // as well as any additional tags provided
  default_tags {
    tags = merge({
      Project      = var.project_name,
      Neighborhood = var.neighborhood
      },
      var.additional_tags
    )
  }
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"

  default_tags {
    tags = merge({
      Project      = var.project_name,
      Neighborhood = var.neighborhood
      },
      var.additional_tags
    )
  }
}

data "aws_iam_openid_connect_provider" "github" {
  arn = "arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

module "keys" {
  source = "./modules/keys"

  resource_prefix = local.resource_prefix
  stage           = var.stage
  ops_group_name  = var.ops_group_name

  github_oidc_provider_arn = data.aws_iam_openid_connect_provider.github.arn
  github_organization      = var.github_organization
  github_repo              = var.github_repo

  providers = {
    aws      = aws
    aws.east = aws.east
  }
}

module "server" {
  source = "./modules/server"

  resource_prefix     = local.resource_prefix
  instance_type       = var.instance_type
  stage               = var.stage
  volume_size         = var.volume_size
  kms_key_arn_west    = module.keys.kms_key_arn_west
  kms_key_arn_east    = module.keys.kms_key_arn_east
  neighborhood        = lower(var.neighborhood)
  github_organization = var.github_organization
  github_repo         = var.github_repo
}

module "ops-roles" {
  source = "./modules/ops-roles"

  resource_prefix       = local.resource_prefix
  stage                 = var.stage
  ops_group_name        = var.ops_group_name
  autoscaling_group_arn = module.server.autoscaling_group_arn

  github_oidc_provider_arn = data.aws_iam_openid_connect_provider.github.arn
  github_organization      = var.github_organization
  github_repo              = var.github_repo
}

resource "aws_resourcegroups_group" "this" {
  name = "${local.resource_prefix}-group"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"],
      TagFilters = [{
        "Key"    = "Project",
        "Values" = [var.project_name]
        }, {
        "Key"    = "Neighborhood",
        "Values" = [var.neighborhood]
      }]
    })
  }
}