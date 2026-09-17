output "address_prefix_id" {
  value = var.existing_address_prefix ? data.ibm_is_vpc_address_prefix.existing[0].id : ibm_is_vpc_address_prefix.new[0].id
}
