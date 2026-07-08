resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                 = "system"
    node_count           = var.system_node_count
    vm_size              = var.system_vm_size
    os_disk_size_gb      = 30
    vnet_subnet_id       = var.aks_subnet_id
    auto_scaling_enabled = true
    min_count            = var.system_min_count
    max_count            = var.system_max_count
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  network_profile {
    # Azure CNI uses per-node IPs and is the more production-friendly option, but it can hit
    # vCPU/quotas on trial subscriptions. Kubenet is lighter-weight and may be easier to fit,
    # but it offers less network isolation and fewer advanced features.
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_vm_size
  node_count            = var.user_node_count
  auto_scaling_enabled  = true
  min_count             = var.user_min_count
  max_count             = var.user_max_count
  mode                  = "User"
  os_disk_size_gb       = 30
  vnet_subnet_id        = var.aks_subnet_id

  # Autoscaler changes node_count outside of Terraform's knowledge (2 -> 3 -> 4 etc.).
  # Without this, every `terraform plan` would try to "correct" it back to node_count,
  # fighting the autoscaler and risking unwanted scale-downs.
  lifecycle {
    ignore_changes = [node_count]
  }
}

# AGIC integration can be added later if ingress controller support is required.