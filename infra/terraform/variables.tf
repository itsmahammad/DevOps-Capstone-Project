variable "project_name" {
  description = "Base prefix used for naming resources."
  type        = string
  default     = "bugslayers"
}

variable "location" {
  description = "Azure region for the production deployment. Prefer West Europe or Germany West Central for trial quotas."
  type        = string
  default     = "westeurope"
  # Trial subscriptions can hit quota or regional availability issues; if deployment fails,
  # switch to Germany West Central as a common fallback.
}

variable "tenant_id" {
  description = "Azure tenant ID used for Key Vault access policies."
  type        = string
}

variable "sql_admin_login" {
  description = "Administrator login name for Azure SQL."
  type        = string
  default     = "sqladmin"
}
