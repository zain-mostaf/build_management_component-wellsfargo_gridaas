output "windows_vsi_ip_addresses" {
  value = {
    for idx, vni in ibm_is_virtual_network_interface.windows_vni :
    ibm_is_instance.windows_instance[idx].name => {
      name       = ibm_is_instance.windows_instance[idx].name
      ip_address = vni.primary_ip[0].address
    }
  }
}

output "instance_names" {
  value = [for windows_instance in ibm_is_instance.windows_instance : windows_instance.name]
}

output "vni_ids" {
  description = "Map of Windows instance name to its Virtual Network Interface ID"
  value = {
    for idx, vni in ibm_is_virtual_network_interface.windows_vni :
    ibm_is_instance.windows_instance[idx].name => vni.id
  }
}
