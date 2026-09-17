data "ibm_is_subnet" "subnet" {
  count               = var.subnet_name_existance ? 1 : 0
  name                = var.subnet_name
  vpc          = var.vpc_id
}

resource "ibm_is_subnet" "subnet" {
  count              = var.subnet_name_existance ? 0 : 1
  name               = var.subnet_name
  vpc                = var.vpc_id
  ipv4_cidr_block    = var.ipv4_cidr_block
  zone               = var.zone
}
