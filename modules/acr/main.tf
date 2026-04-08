# Create Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # Enable admin user for manual image pushes if needed
  admin_enabled = var.admin_enabled

  # Geo-replication for multi-region support (optional)
  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = try(georeplications.value.zone_redundancy_enabled, false)
      regional_endpoint_enabled = try(georeplications.value.regional_endpoint_enabled, false)
    }
  }

  # Network rules for security (optional)
  network_rule_bypass_option    = var.network_rule_bypass_option
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

# Grant AKS cluster permission to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_principal_id
}

# Optional: Role assignment for AKS to push images if needed
resource "azurerm_role_assignment" "aks_acr_push" {
  count = var.enable_aks_push ? 1 : 0

  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = var.aks_principal_id
}
