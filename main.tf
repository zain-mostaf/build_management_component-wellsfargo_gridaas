module "resource_group" {
  source                           = "./module/ibm_resource_group_module"
  resourceGroup_existance          = var.resourceGroup_existance
  resource_group_name              = var.resource_group_name
}

module "VPC" {
  source                           = "./module/ibm_is_vpc_module"
  vpc_name                         = var.vpc_name
  existing_vpc                     = var.existing_vpc
  resource_group_id                = module.resource_group.resource_group_id
}

module "vpc_address_prefix" {
  for_each                         = var.address_prefixes
  source                           = "./module/ibm_is_vpc_address_prefix_module"
  existing_address_prefix          = var.existing_address_prefix
  address_prefix_name              = each.key
  zone                             = var.zone
  vpc_id                           = module.VPC.vpc_id
  cidr                             = each.value
}

module "subnet" {
  source                           = "./module/ibm_is_subnet_module"
  for_each                         = { for idx, subnet in var.subnets : subnet.name => subnet }
  subnet_name_existance            = var.subnet_exists
  subnet_name                      = each.value.name
  vpc_id                           = module.VPC.vpc_id
  ipv4_cidr_block                  = each.value.cidr
  zone                             = var.zone
  depends_on                       = [module.vpc_address_prefix]
}

module "security_group" {
  source                           = "./module/ibm_security_group_module"
  create_new_security_groups       = var.security_groups_exists
    existing_security_group_names  = distinct(concat(var.linux_instances_jump_server_sg, var.windows_instances_AD_sg))
  vpc_id                           = module.VPC.vpc_id
  resource_group_id                = module.resource_group.resource_group_id
  security_group_rules             = var.security_group_rules
}

module "ssh_key" {
  source                           = "./module/ibm_ssh_key_module"
  ssh_key_required                 = var.ssh_key_required
  ssh_key_name                     = var.ssh_key_name
  public_key                       = var.public_key
}





module "linux_instances_jump_server" {
  source                          = "./module/ibm_linux_vsi_module"
  instance_name                   = format("%s-jump-host", var.prefix_name)
  vni_name                        = format("%s-jump-host-vni", var.prefix_name)
  instance_count                  = var.linux-jump-server_instance_count
  image_id                        = var.linux_image_id
  profile                         = var.linux_profile
  vpc_id                          = module.VPC.vpc_id
  zone                            = var.zone
  security_group_id               = [for sg_name in var.linux_instances_jump_server_sg : module.security_group.security_group_ids[sg_name]]
  ssh_key_id                      = module.ssh_key.ssh_key_id
  resource_group_id               = module.resource_group.resource_group_id
  ldap_starting_ip_offset         = var.Jump_server_starting_ip_offset
  subnet_id                       = module.subnet[var.subnets[1].name].subnet_id
  subnet                          = var.subnets[1].cidr
}

module "windows_instances_AD" {
  source                          = "./module/ibm_win_ad_vsi_module"
  instance_name                   = format("%s-ad", var.prefix_name)
  vni_name                        = format("%s-ad-vni", var.prefix_name)
  instance_count                  = var.AD_windows_instance_count
  image_id                        = var.windows_image_id
  profile                         = var.windows_profile
  vpc_id                          = module.VPC.vpc_id
  zone                            = var.zone
  security_group_id               = [for sg_name in var.windows_instances_AD_sg : module.security_group.security_group_ids[sg_name]]
  ssh_key_id                      = module.ssh_key.ssh_key_id
  resource_group_id               = module.resource_group.resource_group_id
  ad_starting_ip_offset           = var.ad_starting_ip_offset
  subnet_id                       = module.subnet[var.subnets[1].name].subnet_id
  subnet                          = var.subnets[1].cidr
}

module "windows_instances_Jump" {
  source                          = "./module/ibm_win_ad_vsi_module"
  instance_name                   = format("%s-win-jh", var.prefix_name)
  vni_name                        = format("%s-win-jh-vni", var.prefix_name)
  instance_count                  = var.Jump_windows_instance_count
  image_id                        = var.windows_image_id
  profile                         = var.windows_profile
  vpc_id                          = module.VPC.vpc_id
  zone                            = var.zone
  security_group_id               = [for sg_name in var.windows_instances_Jump_sg : module.security_group.security_group_ids[sg_name]]
  ssh_key_id                      = module.ssh_key.ssh_key_id
  resource_group_id               = module.resource_group.resource_group_id
  ad_starting_ip_offset           = var.Jump_starting_ip_offset
  subnet_id                       = module.subnet[var.subnets[1].name].subnet_id
  subnet                          = var.subnets[1].cidr
}

module "dns_linux_jump_server" {
  source              = "./module/ibm_dns_record_module"
  existing_dns_zone   = var.existing_dns_zone
  dns_instance_id     = var.dns_instance_id
  dns_zone_name       = var.dns_zone_name
  dns_zone_id         = var.dns_zone_id
  ttl                 = var.dns_ttl
  resource_group_id   = module.resource_group.resource_group_id
  ip_addresses        = module.linux_instances_jump_server.reserved_ip_addresses
  hostnames           = [for i in range(var.linux-jump-server_instance_count) : format("%s-jump-host-%1d", var.prefix_name, i + 1)]
  depends_on          = [module.linux_instances_jump_server]
}

module "dns_windows_AD" {
  source              = "./module/ibm_dns_record_module"
  existing_dns_zone   = var.existing_dns_zone
  dns_instance_id     = var.dns_instance_id
  dns_zone_name       = var.dns_zone_name
  dns_zone_id         = var.dns_zone_id
  ttl                 = var.dns_ttl
  resource_group_id   = module.resource_group.resource_group_id
  ip_addresses        = module.windows_instances_AD.windows_vsi_ip_addresses
  hostnames           = [for i in range(var.AD_windows_instance_count) : format("%s-ad-%1d", var.prefix_name, i + 1)]
  depends_on          = [module.windows_instances_AD]
}

module "dns_windows_Jump" {
  source              = "./module/ibm_dns_record_module"
  existing_dns_zone   = var.existing_dns_zone
  dns_instance_id     = var.dns_instance_id
  dns_zone_name       = var.dns_zone_name
  dns_zone_id         = var.dns_zone_id
  ttl                 = var.dns_ttl
  resource_group_id   = module.resource_group.resource_group_id
  ip_addresses        = module.windows_instances_Jump.windows_vsi_ip_addresses
  hostnames           = [for i in range(var.Jump_windows_instance_count) : format("%s-win-jh-%1d", var.prefix_name, i + 1)]
  depends_on          = [module.windows_instances_Jump]
}
