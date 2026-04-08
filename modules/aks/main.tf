# Create Azure Kubernetes Service Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name           = var.default_node_pool_name
    node_count     = var.default_node_pool_count
    vm_size        = var.default_node_pool_vm_size
    vnet_subnet_id = var.subnet_id

    tags = var.tags
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  http_application_routing_enabled = var.enable_http_application_routing
  azure_policy_enabled             = var.enable_azure_policy

  tags = var.tags

  depends_on = [var.subnet_id]
}

# Create additional node pools if needed
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each              = var.additional_node_pools
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  vnet_subnet_id        = var.subnet_id

  tags = var.tags
}
