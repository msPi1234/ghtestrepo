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
