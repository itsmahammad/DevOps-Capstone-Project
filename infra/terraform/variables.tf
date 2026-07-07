variable "resource_group_name" {
  type    = string
  default = "rg-ats-prod"
}

variable "location" {
  type    = string
  default = "germanywestcentral"
}

variable "acr_name" {
  type    = string
  default = "atsacrprod001"
}

variable "log_analytics_name" {
  type    = string
  default = "log-ats-prod"
}

variable "vnet_name" {
  type    = string
  default = "vnet-ats-prod"
}

variable "vnet_address_space" {
  type    = string
  default = "10.20.0.0/16"
}

variable "aks_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "private_endpoint_subnet_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "aks_name" {
  type    = string
  default = "aks-ats-prod"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29.7"
}

variable "sql_server_name" {
  type    = string
  default = "sql-ats-prod-001"
}

variable "sql_admin_login" {
  type    = string
  default = "sqladminuser"
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
  default   = "ChangeMe123!"
}

variable "sql_database_name" {
  type    = string
  default = "sqldb-ats-prod"
}

variable "key_vault_name" {
  type    = string
  default = "kv-ats-prod-001"
}
