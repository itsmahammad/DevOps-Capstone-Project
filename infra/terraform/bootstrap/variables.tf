variable "project_name" {
  description = "Base prefix for deployed resources."
  type        = string
  default     = "devops-capstone"
}

variable "location" {
  description = "Azure region for the bootstrap resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group that will host the remote state storage account."
  type        = string
  default     = "rg-terraform-state"
}
