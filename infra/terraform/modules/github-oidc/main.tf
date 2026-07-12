# GitHub OIDC module
# Creates an Azure AD App Registration + Service Principal + federated identity
# credential so GitHub Actions can authenticate to Azure without static secrets.
#
# The federated credential trusts tokens issued by GitHub's OIDC provider
# (https://token.actions.githubusercontent.com) for the specified repository
# and environment/branch.

resource "azuread_application" "github_actions" {
  display_name     = var.application_name
  description      = "GitHub Actions OIDC identity for ${var.repository} — no static secrets."
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "github_actions" {
  client_id   = azuread_application.github_actions.client_id
  description = "Service principal for GitHub Actions OIDC (${var.repository})"
}

# Federated identity credential — trusts GitHub OIDC tokens for the production environment.
# This allows GitHub Actions workflows using `environment: production` to request
# an Azure AD token without any client secret.
resource "azuread_application_federated_identity_credential" "github_oidc_production" {
  application_id = azuread_application.github_actions.id
  display_name   = "github-oidc-production"
  description    = "GitHub Actions OIDC for ${var.repository} (production environment)"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  # Subject matches: repo:<org>/<repo>:environment:production
  subject = "repo:${var.repository}:environment:production"
}

# Federated identity credential — trusts GitHub OIDC tokens for PR workflows (branch ref).
# This allows terraform plan on pull requests without requiring the production environment.
resource "azuread_application_federated_identity_credential" "github_oidc_branch" {
  application_id = azuread_application.github_actions.id
  display_name   = "github-oidc-branch"
  description    = "GitHub Actions OIDC for ${var.repository} (main branch)"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  # Subject matches: repo:<org>/<repo>:ref:refs/heads/main
  subject = "repo:${var.repository}:ref:refs/heads/main"
}

# Grant the GitHub Actions identity Contributor on the resource group so
# Terraform can manage all infrastructure resources.
resource "azurerm_role_assignment" "contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Grant AcrPush so GitHub Actions can push container images to ACR.
resource "azurerm_role_assignment" "acr_push" {
  scope                = var.acr_id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions.object_id
}