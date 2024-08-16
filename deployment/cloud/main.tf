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

module "shutdown" {
  source = "./modules/shutdown"
  
  asg_name = module.server.asg_name
  asg_arn = module.server.asg_arn
}