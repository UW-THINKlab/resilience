variable "resource_prefix" {
    description = "The resource prefix is a combination of the project name and neighborhood. This will be used to name all resources in this module."
    type        = string
}

variable "instance_type" {
    description = "The instance type to use for the server"
    type        = string
}