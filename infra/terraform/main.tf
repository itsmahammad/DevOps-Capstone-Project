module "resource_group" {
  source   = "./modules/resource-group"
  name     = "rg-${var.project_name}-prod"
  location = var.location
}

module "networking" {
  source                       = "./modules/networking"
  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  vnet_name                    = "vnet-${var.project_name}-prod"
  address_space                = "10.0.0.0/16"
  aks_subnet_cidr              = "10.0.1.0/24"
  private_endpoint_subnet_cidr = "10.0.2.0/24"
}

module "log_analytics" {
  source              = "./modules/log-analytics"
  name                = "log-${var.project_name}-prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

module "aks" {
  source                     = "./modules/aks"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  cluster_name               = "aks-${var.project_name}-prod"
  dns_prefix                 = "${var.project_name}-prod"
  aks_subnet_id              = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  system_node_count          = 1
  system_vm_size             = "Standard_B2s"
  user_node_count            = 2
  user_vm_size               = "Standard_B2s"
  user_min_count             = 2
  user_max_count             = 4
}

module "acr" {
  source              = "./modules/acr"
  name                = "acr${replace(var.project_name, "-", "")}prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  aks_principal_id    = module.aks.principal_id
}

module "key_vault" {
  source              = "./modules/key-vault"
  name                = "kv-${var.project_name}-prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tenant_id           = var.tenant_id
  aks_principal_id    = module.aks.principal_id
}

module "sql" {
  source                     = "./modules/sql"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  server_name                = "sql-${var.project_name}-prod"
  database_name              = "sqldb-${var.project_name}-prod"
  administrator_login        = var.sql_admin_login
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  key_vault_id               = module.key_vault.id
}
