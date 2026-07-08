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
  description = "SKU of the Azure SQL database. GP_S_Gen5 = General Purpose Serverless Gen5."
  type        = string
  default     = "GP_S_Gen5"
}

variable "max_size_gb" {
  description = "Maximum size in GB for the Azure SQL database."
  type        = number
  default     = 32
}

variable "auto_pause_delay_in_minutes" {
  description = "Minutes of inactivity before the serverless database auto-pauses (60 minimum)."
  type        = number
  default     = 60
}

variable "min_capacity" {
  description = "Minimum vCores for the serverless database (0.5 or 1 for Gen5)."
  type        = number
  default     = 1
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint."
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault into which the generated SQL password will be stored."
  type        = string
}
