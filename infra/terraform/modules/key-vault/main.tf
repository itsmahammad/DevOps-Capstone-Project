resource "azurerm_key_vault" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.aks_principal_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
