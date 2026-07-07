variable "name" {
  description = "Name of the Azure Container Registry."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the ACR."
  type        = string
}

variable "location" {
  description = "Azure region for the container registry."
  type        = string
}

variable "aks_principal_id" {
  description = "Principal ID of the AKS managed identity that should pull from the registry."
  type        = string
}
