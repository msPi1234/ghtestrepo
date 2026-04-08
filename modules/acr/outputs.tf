output "registry_id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.main.id
}

output "registry_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "The URL that can be used to login to the container registry"
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "The username associated with the Container Registry admin account (if admin enabled)"
  value       = try(azurerm_container_registry.main.admin_username, null)
  sensitive   = true
}

output "admin_password" {
  description = "The password associated with the Container Registry admin account (if admin enabled)"
  value       = try(azurerm_container_registry.main.admin_password, null)
  sensitive   = true
}

output "registry_fqdn" {
  description = "Fully Qualified Domain Name (FQDN) of the registry"
  value       = azurerm_container_registry.main.login_server
}

output "identity_principal_id" {
  description = "The principal ID of the registry's managed identity"
  value       = try(azurerm_container_registry.main.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "The tenant ID of the registry's managed identity"
  value       = try(azurerm_container_registry.main.identity[0].tenant_id, null)
}
