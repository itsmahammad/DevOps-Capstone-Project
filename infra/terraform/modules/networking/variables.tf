variable "resource_group_name" {
  description = "Name of the resource group where the networking resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region for the networking resources."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "CIDR block for the AKS subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_endpoint_subnet_cidr" {
  description = "CIDR block for the private endpoint subnet."
  type        = string
  default     = "10.0.2.0/24"
}
