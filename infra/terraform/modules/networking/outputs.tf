output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet."
  value       = azurerm_subnet.aks.id
}

output "private_endpoint_subnet_id" {
  description = "ID of the private endpoint subnet."
  value       = azurerm_subnet.private_endpoint.id
}
