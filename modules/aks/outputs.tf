output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "node_resource_group" {
  description = "Resource group created for AKS nodes"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "kubelet_identity_principal_id" {
  description = "Principal ID of the kubelet identity (for ACR pull permissions). Returns empty string if using service principal auth."
  value       = try(azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id, "")
}
