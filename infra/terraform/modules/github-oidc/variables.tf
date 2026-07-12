variable "application_name" {
  description = "Display name for the Azure AD App Registration."
  type        = string
}

variable "repository" {
  description = "GitHub repository in <org>/<repo> format (e.g. itsmahammad/DevOps-Capstone-Project)."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to grant Contributor access."
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the Azure Container Registry to grant AcrPush access."
  type        = string
}
