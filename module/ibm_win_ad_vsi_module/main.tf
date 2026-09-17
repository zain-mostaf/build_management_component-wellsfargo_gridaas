resource "ibm_is_virtual_network_interface" "windows_vni" {
  count           = var.instance_count
  name            = format("%s-%1d", var.vni_name, count.index + 1)
  subnet          = var.subnet_id
  resource_group  = var.resource_group_id
  security_groups = var.security_group_id
  primary_ip {
    address     = cidrhost(var.subnet, count.index + var.ad_starting_ip_offset)
    auto_delete = true
  }
}

resource "ibm_is_instance" "windows_instance" {
  count          = var.instance_count
  name           = format("%s-%1d", var.instance_name, count.index + 1)
  image          = var.image_id
  profile        = var.profile
  vpc            = var.vpc_id
  zone           = var.zone
  keys           = [var.ssh_key_id]
  resource_group = var.resource_group_id
  primary_network_attachment {
    name = "eth0"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.windows_vni[count.index].id
    }
  }
  lifecycle {
    ignore_changes = [user_data, image]
  }
}
