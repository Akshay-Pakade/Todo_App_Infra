resource "azurerm_network_interface_backend_address_pool_association" "pool_association" {
  network_interface_id    = data.azurerm_network_interface.nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.backend_pool.id
}

