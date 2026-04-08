output "resource_group_id" {
  description = "The ID of the created resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the created resource group"
  value       = azurerm_resource_group.main.location
}

# Networking Module Outputs
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = module.networking.aks_subnet_id
}

output "aks_subnet_name" {
  description = "Name of the AKS subnet"
  value       = module.networking.aks_subnet_name
}

# AKS Module Outputs
output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks.cluster_id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.fqdn
}

output "aks_kube_config" {
  description = "Kubernetes configuration (sensitive)"
  value       = module.aks.kube_config
  sensitive   = true
}

output "aks_node_resource_group" {
  description = "Resource group created for AKS nodes"
  value       = module.aks.node_resource_group
}

# Service Principal Output
output "service_principal_id" {
  description = "ID of the AKS Service Principal"
  value       = azuread_service_principal.aks.id
}

output "service_principal_display_name" {
  description = "Display name of the AKS Service Principal"
  value       = azuread_service_principal.aks.display_name
}

# ============================================================================
# ACR (Azure Container Registry) Outputs
# ============================================================================

output "acr_registry_id" {
  description = "ID of the Azure Container Registry"
  value       = module.acr.registry_id
}

output "acr_registry_name" {
  description = "Name of the Azure Container Registry"
  value       = module.acr.registry_name
}

output "acr_login_server" {
  description = "The login server URL for the container registry"
  value       = module.acr.login_server
}

output "acr_fqdn" {
  description = "Fully Qualified Domain Name (FQDN) of the registry"
  value       = module.acr.registry_fqdn
}

output "acr_admin_username" {
  description = "Admin username for the container registry (if admin enabled)"
  value       = module.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password for the container registry (if admin enabled)"
  value       = module.acr.admin_password
  sensitive   = true
}

# ============================================================================
# AKS-ACR Integration Info
# ============================================================================

output "aks_integration_info" {
  description = "Information for integrating AKS with ACR"
  value = {
    aks_cluster_name   = module.aks.cluster_name
    acr_login_server   = module.acr.login_server
    integration_method = "Managed Identity (automatic via AcrPull role)"
    usage_example      = "kubectl create deployment app --image=${module.acr.login_server}/myimage:latest"
  }
}
