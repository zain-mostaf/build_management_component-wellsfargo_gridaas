output "ssh_key_id" {
  description = "The ID of the SSH key if required"
  value       = var.ssh_key_required ? (length(local.ssh_key) > 0 ? local.ssh_key[0].id : ibm_is_ssh_key.ssh_key[0].id) : null
}
