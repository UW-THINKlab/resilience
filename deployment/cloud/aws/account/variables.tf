variable "account_resource_prefix" {
  description = "Prefix to apply to all account resources"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "account_additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "ops_group_name" {
  description = "The name of the admin group"
  type        = string
  default     = "ssec-eng"
}