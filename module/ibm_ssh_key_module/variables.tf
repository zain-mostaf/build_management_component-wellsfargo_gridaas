variable "ssh_key_required" {
  description = "Flag to determine if an SSH key is required"
  type        = bool
}

variable "ssh_key_name" {
  description = "Name of the SSH key"
  type        = string
  default     = ""  # Empty string by default when ssh_key_required is false
}

variable "public_key" {
  description = "Public key content for the SSH key"
  type        = string
  default     = ""  # Empty string by default when ssh_key_required is false
}
