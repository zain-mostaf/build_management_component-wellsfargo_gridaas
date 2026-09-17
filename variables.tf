## API Key variable
variable "ibmcloud_api_key" {
  description = "APIkey value"
  type        = string
  sensitive   = true
}

variable "region" {
  type        = string
  description = "region name"
}

# ================Resource Group input variables=========================
variable "resourceGroup_existance" {
  description = "Set to true if the resource group already exists, false to create a new one"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}
# =================== VPC =======================
variable "existing_vpc" {
  description = "Set to true if the VPC already exists, false to create a new one"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

#============================Address prefix==========================
variable "existing_address_prefix" {
  type        = bool
  description = "true if using an existent address prefix and false if using a new address prefix"
  default     = true
}

variable "address_prefixes" {
  description = "Map of address prefix names to CIDR blocks"
  type        = map(string)
}

variable "zone" {
  type        = string
  description = "the zone for a new vpc address prefix"
}


#==================subnet ==================
variable "subnet_exists" {
  description = "Set to true if the subnet already exists, false to create a new one"
  type        = bool
  default     = true
}

variable "subnets" {
  type = list(object({
    name  = string
    cidr  = string
  }))
}
#=================== security group ======================
variable "security_groups_exists" {
  description = "Set to true if the Security group already exists, false to create a new one"
  type        = bool
  default     = true
}

variable "security_group_rules" {
  default = []
  type = list(object({
    name = string
    rules = optional(list(object({
      name       = string
      direction  = string
      remote     = string
      ip_version = optional(string, "ipv4")
      icmp = optional(object({
        code = optional(number)
        type = optional(number)
      }))
      tcp = optional(object({
        port_min = number
        port_max = number
      }))
      udp = optional(object({
        port_min = number
        port_max = number
      }))
  }))) }))
}


# ============= ssh key ==========================

variable "ssh_key_required" {
  description = "Set to true if the ssh key already exists, false to create a new one"
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key"
  type        = string
  default     = ""   # Default is empty string since it's not required if ssh_key_required is false
}


variable "public_key" {
  description = "Public key content for the SSH key"
  type        = string
  default     = "" # Default is empty string
}



# =================== Naming prefix =======================
variable "prefix_name" {
  description = "Prefix used to name all provisioned resources"
  type        = string
}

# =================== Linux VSI =======================
variable "linux_image_id" {
  description = "Image ID for Linux instances"
  type        = string
}

variable "linux_profile" {
  description = "Profile for Linux instances"
  type        = string
  default     = "cx2-4x8"
}

variable "linux_instances_rhel_repo_sg" {
  description = "List of security groups for Linux RHEL repo server"
  type        = list(string)
  default     = []
}

################### Jump Server #######################
variable "linux_instances_jump_server_sg" {
  description = "List of security groups for Jump server"
  type        = list(string)
}

variable "linux-jump-server_instance_count" {
  description = "Number of Jump Server instance and the mix of number 3"
  type        = number
  
  validation {
    condition     = var.linux-jump-server_instance_count <= 3
    error_message = "The linux-jump-server_instance_count must be set to 3."
  }
  
}
variable "Jump_server_starting_ip_offset" {
  description = "Offset for IP addresses"
  type        = number
  default     = 30
}
#================================ AD Windows VSI ==================
variable "windows_profile" {
  description = "Profile for Linux instances"
  type        = string
  default     = "cx2-8x16"
}

variable "windows_image_id" {
  description = "Image ID for Windows 2019 or 2022"
  type        = string
  default     = "r006-261e13be-09da-4b7d-9390-a037c7282fbf"
}

variable "AD_windows_instance_count" {
  description = "Number of Linux instances"
  type        = number
  
  validation {
    condition     = var.AD_windows_instance_count <= 3
    error_message = "The AD_windows_instance_count must be set to 3."
  }
}

variable "ad_starting_ip_offset" {
  description = "Offset for IP addresses"
  type        = number
  default     = 30
}

 

variable "windows_instances_AD_sg" {
  description = "List of security groups for Windows Active Directory"
  type        = list(string)
}

variable "windows_instances_KMS_sg" {
  description = "List of security groups for Windows KMS server"
  type        = list(string)
  default     = []
}

variable "windows_instances_WSUS_sg" {
  description = "List of security groups for Windows WSUS server"
  type        = list(string)
  default     = []
}

# ################ Windows Jump ####################
variable "Jump_windows_instance_count" {
  description = "Number of Linux instances"
  type        = number
  validation {
    condition     = var.Jump_windows_instance_count <= 3
    error_message = "The Jump_windows_instance_count must be set to 3."
  }
}

variable "windows_instances_Jump_sg" {
  description = "List of security groups for Windows Jump Server"
  type        = list(string)
}


variable "Jump_starting_ip_offset" {
  description = "Offset for IP addresses"
  type        = number
  default     = 30
}


