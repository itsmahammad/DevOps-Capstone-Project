output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet identity."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "principal_id" {
  description = "Principal ID of the cluster's system-assigned managed identity."
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}