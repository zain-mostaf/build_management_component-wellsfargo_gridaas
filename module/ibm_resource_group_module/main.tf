data "ibm_resource_group" "resourceGroup" {
    count = var.resourceGroup_existance ? 1 : 0
    name = var.resource_group_name
}

resource "ibm_resource_group" "resourceGroup" {
    count = var.resourceGroup_existance ? 0 : 1
    name     = var.resource_group_name
}
