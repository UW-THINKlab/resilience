variable "resource_prefix" {
  description = "The resource prefix is a combination of the project name and neighborhood. This will be used to name all resources in this module."
  type        = string
}

variable "stage" {
  description = "Which stage this infrastructure's being deployed to - dev, beta, prod, etc."
  type        = string

  validation {
    condition     = can(regex("^(dev|beta|prod)$", var.stage))
    error_message = "Stage must be one of dev, beta, or prod"
  }
}

variable "ops_group_name" {
  description = "The name of the admin group"
  type        = string
}

variable "github_oidc_provider_arn" {
  description = "ARN for the OIDC provider for GitHub Actions"
  type        = string
}

variable "github_organization" {
  description = "Organization that the GitHub repo belongs to"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name that this project lives in"
  type        = string
}