output "server_fqdn" {
  description = "Fully qualified domain name of the Azure SQL server."
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_id" {
  description = "Resource ID of the Azure SQL database."
  value       = azurerm_mssql_database.this.id
}
