variable "existing_address_prefix" {
  type        = bool
  description = "true if using an existing address prefix, false to create a new one"
  default     = false
}

variable "address_prefix_name" {
  type        = string
  description = "The name of the VPC address prefix"
}

variable "zone" {
  type        = string
  description = "The zone for the address prefix"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "cidr" {
  type        = string
  description = "The CIDR block for the address prefix"
}
