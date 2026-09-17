output "reserved_ip_addresses" {
  value = {
    for idx, vni in ibm_is_virtual_network_interface.linux_vni :
    ibm_is_instance.linux_instance[idx].name => {
      name       = ibm_is_instance.linux_instance[idx].name
      ip_address = vni.primary_ip[0].address
    }
  }
}

output "instance_names" {
  value = [for instance in ibm_is_instance.linux_instance : instance.name]
}

output "vni_ids" {
  description = "Map of Linux instance name to its Virtual Network Interface ID"
  value = {
    for idx, vni in ibm_is_virtual_network_interface.linux_vni :
    ibm_is_instance.linux_instance[idx].name => vni.id
  }
}
