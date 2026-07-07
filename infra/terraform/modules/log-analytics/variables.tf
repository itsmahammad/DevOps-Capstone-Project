variable "name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the workspace."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string
}
