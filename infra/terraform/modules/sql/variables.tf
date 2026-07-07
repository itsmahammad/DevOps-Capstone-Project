variable "resource_group_name" {
  description = "Name of the resource group in which to create the SQL resources."
  type        = string
}

variable "location" {
  description = "Azure region for the SQL resources."
  type        = string
}

variable "server_name" {
  description = "Name of the Azure SQL logical server."
  type        = string
}

variable "database_name" {
  description = "Name of the Azure SQL database."
  type        = string
}

variable "administrator_login" {
  description = "Administrator login for the SQL server."
  type        = string
}

variable "sku_name" {
  description = "SKU of the Azure SQL database."
  type        = string
  default     = "Basic"
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint."
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault into which the generated SQL password will be stored."
  type        = string
}
