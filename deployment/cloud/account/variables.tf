variable "resource_prefix" {
    description = "Prefix to apply to all resources"
    type        = string
}

variable "account_id" {
    description = "The AWS account ID"
    type        = string
}

variable "additional_tags" {
    description = "Additional tags to apply to resources"
    type        = map(string)
    default = {}
}