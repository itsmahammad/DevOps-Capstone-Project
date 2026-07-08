output "client_id" {
  description = "Client (application) ID of the Azure AD App Registration. Set as GitHub secret AZURE_CLIENT_ID."
  value       = azuread_application.github_actions.client_id
}

output "tenant_id" {
  description = "Tenant ID of the Azure AD tenant. Set as GitHub secret AZURE_TENANT_ID."
  value       = azuread_service_principal.github_actions.application_tenant_id
}

output "object_id" {
  description = "Object ID of the service principal."
  value       = azuread_service_principal.github_actions.object_id
}