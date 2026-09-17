locals {
  security_group_ids = var.create_new_security_groups ? {
    for sg_name in var.existing_security_group_names : sg_name => data.ibm_is_security_group.existing[sg_name].id
  } :  {
    for sg_name, sg in ibm_is_security_group.sg : sg_name => sg.id
  }
}

resource "ibm_is_security_group" "sg" {
  for_each = var.create_new_security_groups ? {} : {
    for sg in var.security_group_rules : sg.name => sg
  }

  name           = each.value.name
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

data "ibm_is_security_group" "existing" {
  for_each = var.create_new_security_groups ? {
    for sg_name in var.existing_security_group_names : sg_name => sg_name
  } : {}

  name = each.value
}



resource "ibm_is_security_group_rule" "sg_rule" {
  for_each = {
    for combination in flatten([
      for sg in var.security_group_rules : [
        for rule in sg.rules : {
          key  = "${sg.name}-${rule.name}"
          sg   = sg
          rule = rule
        }
      ]
    ]) : combination.key => combination
  }

  group     = local.security_group_ids[each.value.sg.name]
  direction = each.value.rule.direction
  remote    = each.value.rule.remote

  dynamic "icmp" {
    for_each = each.value.rule.icmp != null ? [each.value.rule.icmp] : []
    content {
      code = icmp.value.code
      type = icmp.value.type
    }
  }

  dynamic "tcp" {
    for_each = each.value.rule.tcp != null ? [each.value.rule.tcp] : []
    content {
      port_min = tcp.value.port_min
      port_max = tcp.value.port_max
    }
  }

  dynamic "udp" {
    for_each = each.value.rule.udp != null ? [each.value.rule.udp] : []
    content {
      port_min = udp.value.port_min
      port_max = udp.value.port_max
    }
  }
}