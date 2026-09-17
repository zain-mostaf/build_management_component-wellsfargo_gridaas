locals {
  ssh_key = var.ssh_key_required ? flatten([
    for k in data.ibm_is_ssh_keys.all_ssh_keys[0].keys : k
    if k.name == var.ssh_key_name
  ]) : []
}

data "ibm_is_ssh_keys" "all_ssh_keys" {
  count = var.ssh_key_required ? 1 : 0
}

resource "ibm_is_ssh_key" "ssh_key" {
  count      = var.ssh_key_required && length(local.ssh_key) == 0 ? 1 : 0
  name       = var.ssh_key_name
  public_key = var.public_key
}




