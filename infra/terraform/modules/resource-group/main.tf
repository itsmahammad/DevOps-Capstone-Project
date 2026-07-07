resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
