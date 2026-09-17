data "ibm_is_vpc_address_prefix" "existing" {
  count               = var.existing_address_prefix ? 1 : 0
  vpc                 = var.vpc_id
  address_prefix_name = var.address_prefix_name
}

resource "ibm_is_vpc_address_prefix" "new" {
  count = var.existing_address_prefix ? 0 : 1
  name  = var.address_prefix_name
  zone  = var.zone
  vpc   = var.vpc_id
  cidr  = var.cidr
}
