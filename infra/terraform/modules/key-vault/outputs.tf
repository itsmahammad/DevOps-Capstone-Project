output "vault_uri" {
  description = "URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}
