variable "create_new_security_groups" {
  description = "Set to true if the Security group already exists, false to create a new one"
  type        = bool
  default     = true
}

variable "security_group_rules" {
  description = "List of security group rules"
  type = list(object({
    name  = string
    rules = list(object({
      name      = string
      direction = string
      remote    = string
      icmp = object({
        code = number
        type = number
      })
      tcp = object({
        port_min = number
        port_max = number
      })
      udp = object({
        port_min = number
        port_max = number
      })
    }))
  }))
  default = []
}

variable "existing_security_group_names" {
  description = "List of existing security group names"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "resource_group_id" {
  description = "Resource Group ID"
  type        = string
}