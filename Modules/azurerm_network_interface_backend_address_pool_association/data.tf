

data "azurerm_network_interface" "nic" {
  name                = var.nic_name
  resource_group_name = var.resource_group_name
}

data "azurerm_lb" "loadbalancer" {
  name                =var.lb_name
  resource_group_name = var.resource_group_name
}

data "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "testpool"
  loadbalancer_id = data.azurerm_lb.loadbalancer.id
}