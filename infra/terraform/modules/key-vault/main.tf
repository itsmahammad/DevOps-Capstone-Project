data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id

  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true

  # Allow Terraform (current signed-in user / GitHub Actions in the future)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover"
    ]
  }

  # Allow AKS to read secrets
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