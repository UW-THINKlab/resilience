terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
    }
  }
}

locals {
  // The resource prefix is a combination of the project name and neighborhood
  // This will be used to name all resources created by this module
  resource_prefix = join("-", 
    [lower(trimspace(replace(var.project_name, " ", ""))), 
    lower(trimspace(replace(var.neighborhood, " ", "")))]
  )
}

provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = "arn:aws:iam::871683513797:role/supportsphere-deploy"
    session_name = "${local.resource_prefix}-infra-deployment"
    external_id = "${local.resource_prefix}-infra-deployment"
  }

  // Tags all resources created from this provider with {"Project": <project name input>, "Neighborhood": <neighborhood input>}
  // as well as any additional tags provided
  default_tags {
    tags = merge({
        Project = var.project_name,
        Neighborhood = var.neighborhood
      },
      var.additional_tags
    )
  }
}

module "server" {
  source = "./modules/server"
  
  resource_prefix = local.resource_prefix
}

resource "aws_resourcegroups_group" "this" {
    name = "${local.resource_prefix}-group"

    resource_query {
        query = jsonencode({
            ResourceTypeFilters = ["AWS::AllSupported"],
            TagFilters = [{
                "Key" = "Project",
                "Values" = [var.project_name]
            }, {
                "Key" = "Neighborhood",
                "Values" = [var.neighborhood]
            }]
        })
    }
}