variable "resource_group_name" {
  description = "Name of the resource group in which to create the AKS cluster."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy."
  type        = string
  default     = null
}

variable "aks_subnet_id" {
  description = "Subnet ID for the AKS node pool."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace used for monitoring."
  type        = string
}

variable "system_node_count" {
  description = "Initial number of nodes in the system node pool (autoscaler will adjust)."
  type        = number
  default     = 1
}

variable "system_vm_size" {
  description = "VM size for the system node pool."
  type        = string
  default     = "Standard_B2s"
}

variable "system_min_count" {
  description = "Minimum number of nodes for the autoscaling system node pool."
  type        = number
  default     = 1
}

variable "system_max_count" {
  description = "Maximum number of nodes for the autoscaling system node pool."
  type        = number
  default     = 2
}

variable "user_node_count" {
  description = "Initial node count for the user node pool."
  type        = number
  default     = 2
}

variable "user_vm_size" {
  description = "VM size for the user node pool. Standard_B2ms (2 vCPU, 8 GiB) gives headroom for OCR workloads."
  type        = string
  default     = "Standard_B2ms"
}

variable "user_min_count" {
  description = "Minimum number of nodes for the autoscaling user node pool."
  type        = number
  default     = 2
}

variable "user_max_count" {
  # NOTE: 2 (system) + up to 4 (user) = up to 10 vCPUs at Standard_B2s (2 vCPU each).
  # Trial subscriptions often cap regional vCPU quota lower than this. Run
  # `az vm list-usage --location <region> -o table` once the subscription is active,
  # and lower this default if needed before the first apply.
  description = "Maximum number of nodes for the autoscaling user node pool."
  type        = number
  default     = 4
}