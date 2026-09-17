variable "resource_group_id" {
  description = "The ID of the resource group to associate with the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "existing_vpc" {
  description = "Set to true if the VPC already exists, false to create a new one"
  type        = bool
  default     = false
}