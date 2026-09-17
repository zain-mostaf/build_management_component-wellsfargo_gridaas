data "ibm_is_vpc" "existing" {
  count = var.existing_vpc ? 1 : 0
  name  = var.vpc_name
}

resource "ibm_is_vpc" "new" {
  count             = var.existing_vpc ? 0 : 1
  name              = var.vpc_name
  resource_group    = var.resource_group_id
}