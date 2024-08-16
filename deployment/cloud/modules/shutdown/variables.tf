variable "asg_name" {
  description = "The name of the server's autoscaling group that we'll want to scale down"
  type        = string
}

variable "asg_arn" {
  description = "The arn of the server's autoscaling group that we'll want to scale down"
  type        = string
}