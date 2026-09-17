variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "subnet_name_existance" {
  description = "true if using an existent subnet and false if using a new subnet"
  type        = bool
  default = false 
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "ipv4_cidr_block" {
  description = "The IPv4 CIDR block for the subnet (required if creating a new subnet)"
  type        = string
  default     = null
}

variable "zone" {
  description = "The zone for the subnet"
  type        = string
}

