output "vpc_id" {
  value = var.existing_vpc ? data.ibm_is_vpc.existing[0].id : ibm_is_vpc.new[0].id
}