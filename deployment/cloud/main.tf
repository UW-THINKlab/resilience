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
  assume_role {
    role_arn = "arn:aws:iam::871683513797:role/supportsphere-deploy"
    session_name = "supportsphere-infra-deployment"
    external_id = "supportsphere-infra-deployment"
  }

  // Tags all resources created from this provider with {"Project": "Support Sphere", "Neighborhood": "Laurelhurst"}
  default_tags {
    tags = {
      Project = "Support Sphere",
      Neighborhood = "Laurelhurst"
    }
  }
}

module "server" {
  source = "./modules/server"
  
}

resource "aws_resourcegroups_group" "this" {
    name = "support-sphere-laurelhurst-group"

    resource_query {
        query = jsonencode({
            ResourceTypeFilters = ["AWS::AllSupported"],
            TagFilters = [{
                "Key" = "Project",
                "Values" = ["Support Sphere"]
            }, {
                "Key" = "Neighborhood",
                "Values" = ["Laurelhurst"]
            }]
        })
    }
}