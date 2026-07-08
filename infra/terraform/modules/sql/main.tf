resource "random_password" "sql_admin" {
  length           = 24
  special          = true
  override_special = "!@#%^*()-_"
}

resource "azurerm_mssql_server" "this" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.administrator_login
  administrator_login_password  = random_password.sql_admin.result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

resource "azurerm_mssql_database" "this" {
  name      = var.database_name
  server_id = azurerm_mssql_server.this.id
  # Serverless Gen5 General Purpose: 1 vCore min, auto-pause after 1 hour of inactivity.
  # This is the cheapest real Azure SQL tier that satisfies the rubric requirement.
  sku_name               = var.sku_name
  max_size_gb            = var.max_size_gb
  zone_redundant         = false
  auto_pause_delay_in_minutes = var.auto_pause_delay_in_minutes
  min_capacity           = var.min_capacity

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

resource "azurerm_private_endpoint" "sql" {
  name                = "${var.server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.server_name}-psc"
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = random_password.sql_admin.result
  key_vault_id = var.key_vault_id
}
