# ---- DNS zone resolution ----------------------------------------
# When existing_dns_zone = true  → data source looks up the zone by name
# When existing_dns_zone = false → resource creates it
# -----------------------------------------------------------------

variable "existing_dns_zone" {
  description = "true to look up an existing IBM DNS zone, false to create a new one"
  type        = bool
  default     = true
}

variable "dns_instance_id" {
  description = "GUID of the IBM Cloud DNS Services instance"
  type        = string
}

variable "dns_zone_name" {
  description = "DNS zone name (e.g. gridaas.internal)"
  type        = string
}

variable "dns_zone_id" {
  description = "ID of an existing DNS zone (required only when existing_dns_zone = true)"
  type        = string
  default     = ""
}

# ---- Record inputs ----------------------------------------------
# ip_addresses  : list of IP strings for which A + PTR records are created
# hostnames     : parallel list of short hostnames (without the zone suffix)
# Both lists must have the same length.
# -----------------------------------------------------------------

variable "ip_addresses" {
  description = "List of IP addresses to register (one A record + one PTR record per IP)"
  type        = list(string)
}

variable "hostnames" {
  description = "List of short hostnames matching ip_addresses (no trailing dot, no zone suffix)"
  type        = list(string)
}

variable "ttl" {
  description = "TTL in seconds for all DNS records"
  type        = number
  default     = 300
}

variable "resource_group_id" {
  description = "Resource group ID (used when creating a new DNS zone)"
  type        = string
  default     = ""
}
