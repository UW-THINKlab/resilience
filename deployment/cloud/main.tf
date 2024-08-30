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

resource "aws_resourcegroups_group" "support_sphere_group_laurelhurst" {
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