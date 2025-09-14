module "resource_group" {
  source              = "../Modules/azurerm_resource_group"
  resource_group_name = "rg-todo-app"
  location            = "East US"
  
}

module "storage_account"{
    depends_on = [module.resource_group]
    source              = "../Modules/azurerm_storage_account"
    stg_name            = "stgtodoapp"
    resource_group_name = "rg-todo-app"
    location            = "East US"
}

module "vnet" {
    depends_on = [module.resource_group]
  source = "../Modules/azurerm_virtual_network"
    vnet_name            = "vnet-todo-app"
    location             = "East US"
    resource_group_name  = "rg-todo-app"
    address_space = ["10.0.0.0/16"]
}

module "subnet" {
    depends_on = [module.resource_group, module.vnet]
  source = "../Modules/azurerm_subnet"
    subnet_name         = "subnet-todo-app1"
    resource_group_name = "rg-todo-app"
    vnet_name          = "vnet-todo-app"
    address_prefixes   = ["10.0.0.0/24"]
}

module "subnet1" {
  source = "../Modules/azurerm_subnet"
   depends_on = [module.resource_group, module.vnet]
    subnet_name         = "subnet-todo-app2"
    resource_group_name = "rg-todo-app"
    vnet_name          = "vnet-todo-app"
    address_prefixes   = ["10.0.1.0/24"]
}

module "bastionsubnet" {
  source = "../Modules/azurerm_subnet"
   depends_on = [module.resource_group, module.vnet]
    subnet_name         = "AzureBastionSubnet"
    resource_group_name = "rg-todo-app"
    vnet_name          = "vnet-todo-app"
    address_prefixes   = ["10.0.2.0/24"]
}

module "public_ip_bastion" {
    depends_on = [module.resource_group]
  source = "../Modules/azurerm_public_ip"
    public_ip_name      = "pip-bastion"
    location            = "East US"
    resource_group_name = "rg-todo-app"
  
}

module "public_ip" {
    depends_on = [module.resource_group]
  source = "../Modules/azurerm_public_ip"
    public_ip_name      = "pip-todo-app"
    location            = "East US"
    resource_group_name = "rg-todo-app"
  
}

module "vm1" {
depends_on = [module.resource_group, module.vnet, module.subnet1, module.keyvault, module.keyvault_secret_password, module.keyvault_secret_username]
  source = "../Modules/azurerm_virtual_machine"
    subnet_name         = "subnet-todo-app1"
    vnet_name           = "vnet-todo-app"
    resource_group_name = "rg-todo-app"
    nic_name            = "nic-todo-app1"
    location            = "East US"
    vm_name             = "vm-todo-app1"
    vm_size             = "Standard_B1s"
    # admin_username      = "akshay"
    # admin_password      = "Pakade@8899"
    key_vault_name     = "kv-anu"
    username = "admin-username"
    password = "admin-password"
}

module "vm2" {
  source = "../Modules/azurerm_virtual_machine"
        depends_on = [module.resource_group, module.vnet, module.subnet1, module.keyvault, module.keyvault_secret_password, module.keyvault_secret_username]
    subnet_name         = "subnet-todo-app2"
    vnet_name           = "vnet-todo-app"
    resource_group_name = "rg-todo-app"
    nic_name            = "nic-todo-app2"
    location            = "East US"
    vm_name             = "vm-todo-app2"
    vm_size             = "Standard_B1s"
    # admin_username      = "akshay"
    # admin_password      = "Akshay@8899"
    key_vault_name     = "kv-anu"
     username = "admin-username"
    password = "admin-password"
}

module "keyvault" {
    depends_on = [module.resource_group]
  source = "../Modules/azurerm_keyvault"
    key_vault_name      = "kv-anu"
    location            = "East US"
    resource_group_name = "rg-todo-app"
}

module "keyvault_secret_username" {
  source = "../Modules/azurerm_keyvault_secret"
    depends_on = [module.resource_group, module.keyvault]
    key_vault_name      = "kv-anu"
    resource_group_name = "rg-todo-app"
    secret_name         = "admin-username"
    secret_value        = "akshay"
}

module "keyvault_secret_password" {
  source = "../Modules/azurerm_keyvault_secret"
    depends_on = [module.resource_group, module.keyvault]
    key_vault_name      = "kv-anu"
    resource_group_name = "rg-todo-app"
    secret_name         = "admin-password"
    secret_value        = "Akshay@8899"
}


module "mssqlserver" {
  source = "../Modules/azurerm_mssql_database"
  resource_group_name = "rg-todo-app"
  location            = "centralus"
}

module "loadbalancer" {
  source = "../Modules/azurerm_loadbalancer"
    depends_on = [module.resource_group, module.public_ip]
    lb_name             = "lb-todo-app"
    location            = "East US"
    resource_group_name = "rg-todo-app"
    public_ip_name      = "pip-todo-app"
  
}

module "lb_backend_pool_association_vm1" {
  source = "../Modules/azurerm_network_interface_backend_address_pool_association"
    depends_on = [module.resource_group, module.public_ip, module.vm1, module.loadbalancer]
    nic_name            = "nic-todo-app1"
    resource_group_name = "rg-todo-app"
    lb_name             = "lb-todo-app"
  
}

module "lb_backend_pool_association_vm2" {
  source = "../Modules/azurerm_network_interface_backend_address_pool_association"
    depends_on = [module.resource_group, module.public_ip, module.vm2, module.loadbalancer]
    nic_name            = "nic-todo-app2"
    resource_group_name = "rg-todo-app"
    lb_name             = "lb-todo-app"
}

module "azurerm_bastion_host" {
  depends_on = [ module.bastionsubnet, module.public_ip_bastion]
  source = "../Modules/azurerm_bastion"
  subnet_name = "AzureBastionSubnet"
  vnet_name = "vnet-todo-app"
  resource_group_name = "rg-todo-app"
  public_ip_name = "pip-bastion"
  bastion_name = "bastion-todo"
  location = "East Us"
}

module "nsg" {
  source = "../Modules/network_security_group"
  depends_on = [module.resource_group]
  nsg_name = "nsg-todo-app"
  location = "East US"
  resource_group_name = "rg-todo-app"
}