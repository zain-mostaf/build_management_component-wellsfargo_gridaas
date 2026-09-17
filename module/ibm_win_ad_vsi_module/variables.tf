variable "instance_count" {
  description = "Number of Windows instances"
  type        = number
}

variable "image_id" {
  description = "Image ID for Windows instances"
  type        = string
}

variable "profile" {
  description = "Profile for the instances"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "zone" {
  description = "Zone for the instances"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "ssh_key_id" {
  description = "SSH key ID"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group to attach to the instance"
  type        = list(string)
  default     = []
}

variable "resource_group_id" {
  type        = string
  description = "the id of the resource group for a new subnet"
}

variable "instance_name" {
  description = "Name of the Windows instance"
  type        = string
}

variable "vni_name" {
  description = "Base name for the Virtual Network Interface attached to each Windows instance"
  type        = string
}

variable "subnet" {
  description = "Subnet CIDR block"
  type        = string
}


variable "ad_starting_ip_offset" {
  description = "The offset for the starting IP address in the subnet"
  type        = number
  default     = 30 # Example offset; adjust if needed
}




