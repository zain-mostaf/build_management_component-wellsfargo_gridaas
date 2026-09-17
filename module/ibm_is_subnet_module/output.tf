output "subnet_id" {
  description = "The ID of the subnet"
  value       = var.subnet_name_existance ? data.ibm_is_subnet.subnet[0].id : ibm_is_subnet.subnet[0].id
}
