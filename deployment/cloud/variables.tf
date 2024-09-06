variable "project_name" {
    description = "The name of the project -- used for tagging"
    type        = string
}

variable "neighborhood" {
    description = "The neighborhood of the project -- used for tagging"
    type        = string
}

variable "additional_tags" {
    description = "Additional tags to apply to resources"
    type        = map(string)
    default = {}
}

variable "instance_type" {
    description = "The instance type to use for the server"
    type        = string
    default     = "r5.large"
}