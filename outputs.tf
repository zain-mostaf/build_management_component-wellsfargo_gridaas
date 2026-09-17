output "resource_group_id" {
  value = module.resource_group.resource_group_id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.VPC.vpc_id
}

output "address_prefix_ids" {
  description = "The IDs of the address prefixes"
  value = { for k, v in module.vpc_address_prefix : k => v.address_prefix_id }
}


output "subnet_ids" {
  value = { for subnet in var.subnets : subnet.name => module.subnet[subnet.name].subnet_id }
}

output "security_group_ids" {
  value = module.security_group.security_group_ids
}

output "ssh_key_id" {
  value = module.ssh_key.ssh_key_id
}



output "jump_linux_instance_ip_address" {
  description = "Jump Linux instance IP addresses"
  value = module.linux_instances_jump_server.reserved_ip_addresses
}




output "AD_windows_vsi_ip_addresses" {
  description = "Windows AD instance IP addresses"
  value = module.windows_instances_AD.windows_vsi_ip_addresses
}

output "Jump_windows_vsi_ip_addresses" {
  description = "Windows Jump instance IP addresses"
  value = module.windows_instances_Jump.windows_vsi_ip_addresses
}

# ---- DNS outputs -----------------------------------------------
output "dns_zone_id" {
  description = "The ID of the DNS zone used for all records"
  value       = module.dns_linux_jump_server.dns_zone_id
}

output "dns_linux_jump_server_a_records" {
  description = "A record IDs for Linux jump server instances"
  value       = module.dns_linux_jump_server.a_record_ids
}

output "dns_linux_jump_server_ptr_records" {
  description = "PTR record IDs for Linux jump server instances"
  value       = module.dns_linux_jump_server.ptr_record_ids
}

output "dns_windows_AD_a_records" {
  description = "A record IDs for Windows AD instances"
  value       = module.dns_windows_AD.a_record_ids
}

output "dns_windows_AD_ptr_records" {
  description = "PTR record IDs for Windows AD instances"
  value       = module.dns_windows_AD.ptr_record_ids
}

output "dns_windows_Jump_a_records" {
  description = "A record IDs for Windows Jump instances"
  value       = module.dns_windows_Jump.a_record_ids
}

output "dns_windows_Jump_ptr_records" {
  description = "PTR record IDs for Windows Jump instances"
  value       = module.dns_windows_Jump.ptr_record_ids
}

