output "instance_ids" {
  description = "IDs of the Windows VSI instances"
  value       = ibm_is_instance.windows_instance[*].id
}

output "windows_vsi_ip_addresses" {
  description = "Primary IP addresses assigned to each Windows instance VNI"
  value       = ibm_is_virtual_network_interface.windows_vni[*].primary_ip[0].address
}

output "vni_ids" {
  description = "IDs of the Virtual Network Interfaces"
  value       = ibm_is_virtual_network_interface.windows_vni[*].id
}
