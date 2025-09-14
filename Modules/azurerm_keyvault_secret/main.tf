data "azurerm_key_vault" "keyvault" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}
# data "azurerm_client_config" "current" {}
# resource "azurerm_key_vault_access_policy" "policy" {
#   key_vault_id = data.azurerm_key_vault.keyvault.id

#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = data.azurerm_client_config.current.object_id

#   secret_permissions = [
#     "Get",
#     "Set",
#     "List",
#     "Delete"
#   ]
# }

# Create Secret
resource "azurerm_key_vault_secret" "secret" {
  name         = var.secret_name
  value        = var.secret_value
  key_vault_id = data.azurerm_key_vault.keyvault.id

#   depends_on = [azurerm_key_vault_access_policy.terraform_policy]
}
