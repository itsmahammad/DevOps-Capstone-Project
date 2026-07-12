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

variable "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity."
  type        = string
}
