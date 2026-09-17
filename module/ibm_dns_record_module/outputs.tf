output "dns_zone_id" {
  description = "The ID of the DNS zone used (looked up or created)"
  value       = local.zone_id
}

output "a_record_ids" {
  description = "IDs of the created A records"
  value       = ibm_dns_resource_record.a[*].id
}

output "ptr_record_ids" {
  description = "IDs of the created PTR records"
  value       = ibm_dns_resource_record.ptr[*].id
}
