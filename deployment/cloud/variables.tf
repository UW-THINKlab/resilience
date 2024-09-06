variable "project_name" {
    description = "The name of the project -- used for tagging"
    type        = string
}

variable "neighborhood" {
    description = "The neighborhood of the project -- used for tagging"
    type        = string
}

variable "stage" {
    description = "Which stage this infrastructure's being deployed to - dev, beta, prod, etc."
    type        = string

    validation {
        condition = can(regex("^(dev|beta|prod)$", var.stage))
        error_message = "Stage must be one of dev, beta, or prod"
    }
}

variable "additional_tags" {
    description = "Additional tags to apply to resources"
    type        = map(string)
    default = {}
}

variable "instance_type" {
    description = "The instance type to use for the server"
    type        = string
    default     = "t3.medium"
}

variable "volume_size" {
    description = "The instance type to use for the server"
    type        = string
    default     = 16
}