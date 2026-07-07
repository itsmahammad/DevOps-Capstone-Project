variable "name" {
  description = "Name of the Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID that should manage the Key Vault."
  type        = string
}

variable "aks_principal_id" {
  description = "Principal ID of the AKS managed identity that should access the Key Vault."
  type        = string
}
