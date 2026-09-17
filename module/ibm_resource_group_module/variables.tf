variable "resource_group_name" {
    description = "Resource group name"
    type = string
}

variable "resourceGroup_existance" {
    description = "Set to true if the resource group already exists, false to create a new one"
    type = bool
    default = false
}
