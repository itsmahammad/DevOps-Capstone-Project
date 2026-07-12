# SQL module variables.
#
# Serverless-only variables (auto_pause_delay_in_minutes, min_capacity) have been
# removed because the module now uses the Basic provisioned SKU instead of GP_S_Gen5.

variable "resource_group_name" {
  description = "Name of the resource group in which to create the SQL resources."
  type        = string
}

variable "location" {
  description = "Azure region for the SQL resources."
  type        = string
}

variable "server_name" {
  description = "Name of the Azure SQL logical server. Will be lowercased to comply with Azure naming rules."
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
  description = "SKU of the Azure SQL database. Basic = 5 DTU, cheapest provisioned tier (~$5/month)."
  type        = string
  default     = "Basic"
}

variable "max_size_gb" {
  description = "Maximum size in GB for the Azure SQL database. Basic SKU supports up to 2 GB."
  type        = number
  default     = 2
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint."
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault into which the generated SQL password will be stored."
  type        = string
}
