# ---- DNS zone --------------------------------------------------
# Look up the existing zone OR create a new one.
# The local `zone_id` abstracts this so record resources always
# reference a single value regardless of which path was taken.
# ----------------------------------------------------------------

data "ibm_dns_zones" "existing_zones" {
  count       = var.existing_dns_zone ? 1 : 0
  instance_id = var.dns_instance_id
}

locals {
  # When looking up: filter the list of zones by name to get the ID.
  # When creating:   use the newly-created zone's ID.
  zone_id = var.existing_dns_zone ? (
    length([
      for z in data.ibm_dns_zones.existing_zones[0].dns_zones :
      z.zone_id if z.name == var.dns_zone_name
    ]) > 0
    ? [
        for z in data.ibm_dns_zones.existing_zones[0].dns_zones :
        z.zone_id if z.name == var.dns_zone_name
      ][0]
    : var.dns_zone_id   # fallback: caller passed the ID directly
  ) : ibm_dns_zone.new[0].zone_id
}

resource "ibm_dns_zone" "new" {
  count       = var.existing_dns_zone ? 0 : 1
  name        = var.dns_zone_name
  instance_id = var.dns_instance_id
}

# ---- A records (hostname → IP) ---------------------------------
resource "ibm_dns_resource_record" "a" {
  count       = length(var.ip_addresses)
  instance_id = var.dns_instance_id
  zone_id     = local.zone_id
  type        = "A"
  name        = var.hostnames[count.index]
  rdata       = var.ip_addresses[count.index]
  ttl         = var.ttl
}

# ---- PTR records (IP → FQDN) -----------------------------------
resource "ibm_dns_resource_record" "ptr" {
  count       = length(var.ip_addresses)
  instance_id = var.dns_instance_id
  zone_id     = local.zone_id
  type        = "PTR"
  name        = var.ip_addresses[count.index]
  rdata       = format("%s.%s", var.hostnames[count.index], var.dns_zone_name)
  ttl         = var.ttl
}
