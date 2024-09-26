variable "resource_prefix" {
    description = "The resource prefix is a combination of the project name and neighborhood. This will be used to name all resources in this module."
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

variable "instance_type" {
    description = "The instance type to use for the server"
    type        = string
}

variable "volume_size" {
    description = "The instance volume size to use for the server"
    type        = string

}

variable "kms_key_arn_west" {
    description = "The ARN of the KMS key to use for encryption in the west region"
    type        = string
}

variable "kms_key_arn_east" {
    description = "The ARN of the KMS key to use for encryption in the east region"
    type        = string
}