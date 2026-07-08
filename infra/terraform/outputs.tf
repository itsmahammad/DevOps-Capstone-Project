output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "acr_login_server" {
  description = "Login server for the Azure Container Registry."
  value       = module.acr.login_server
}

output "sql_server_fqdn" {
  description = "FQDN of the Azure SQL server."
  value       = module.sql.server_fqdn
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = module.key_vault.vault_uri
}

output "resource_group_name" {
  description = "Name of the main resource group."
  value       = module.resource_group.name
}

output "github_oidc_client_id" {
  description = "Client ID of the GitHub Actions OIDC App Registration. Set as GitHub secret AZURE_CLIENT_ID."
  value       = module.github_oidc.client_id
  sensitive   = true
}

output "github_oidc_tenant_id" {
  description = "Tenant ID for the GitHub Actions OIDC identity. Set as GitHub secret AZURE_TENANT_ID."
  value       = module.github_oidc.tenant_id
  sensitive   = true
}
