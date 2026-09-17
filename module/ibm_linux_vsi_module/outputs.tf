output "instance_ids" {
  description = "IDs of the Linux VSI instances"
  value       = ibm_is_instance.linux_instance[*].id
}

output "reserved_ip_addresses" {
  description = "Primary IP addresses assigned to each Linux instance VNI"
  value       = ibm_is_virtual_network_interface.linux_vni[*].primary_ip[0].address
}

output "vni_ids" {
  description = "IDs of the Virtual Network Interfaces"
  value       = ibm_is_virtual_network_interface.linux_vni[*].id
}
