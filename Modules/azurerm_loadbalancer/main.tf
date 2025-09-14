variable "lb_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "public_ip_name" {}


data "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_lb" "loadbalancer" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = data.azurerm_public_ip.public_ip.id
  }

}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.loadbalancer.id
  name            = "testpool"
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id       = azurerm_lb.loadbalancer.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.backend_pool.id
  ]
}