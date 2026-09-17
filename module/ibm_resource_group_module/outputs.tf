output "resource_group_id" {
  value = var.resourceGroup_existance ? data.ibm_resource_group.resourceGroup[0].id : ibm_resource_group.resourceGroup[0].id
}
