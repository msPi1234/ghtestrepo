# Create the resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = merge(
    var.common_tags,
    {
      CreatedBy   = "Terraform"
      Environment = var.environment
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}

resource "azuread_application" "aks" {
  display_name = "${var.resource_group_name}-aks-sp"
}

# Create Service Principal for AKS
resource "azuread_service_principal" "aks" {
  client_id = azuread_application.aks.client_id

  tags = ["AKS"]
}

resource "azuread_service_principal_password" "aks" {
  service_principal_id = azuread_service_principal.aks.id
  end_date_relative    = "8760h" # 1 year
}

# Create role assignment for Service Principal
resource "azurerm_role_assignment" "aks" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks.id
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  aks_subnet_name     = var.aks_subnet_name
  aks_subnet_prefix   = var.aks_subnet_prefix
  nsg_name            = var.nsg_name
  tags                = local.common_tags
}

# AKS Module
module "aks" {
  source = "./modules/aks"

  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  cluster_name                    = var.cluster_name
  dns_prefix                      = var.dns_prefix
  kubernetes_version              = var.kubernetes_version
  subnet_id                       = module.networking.aks_subnet_id
  default_node_pool_count         = var.default_node_pool_count
  default_node_pool_vm_size       = var.default_node_pool_vm_size
  client_id                       = azuread_application.aks.client_id
  client_secret                   = azuread_service_principal_password.aks.value
  network_plugin                  = var.network_plugin
  network_policy                  = var.network_policy
  service_cidr                    = var.service_cidr
  dns_service_ip                  = var.dns_service_ip
  enable_http_application_routing = var.enable_http_application_routing
  enable_azure_policy             = var.enable_azure_policy
  tags                            = local.common_tags

  depends_on = [azurerm_role_assignment.aks]
}

# ACR Module (Container Registry)
module "acr" {
  source = "./modules/acr"

  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  registry_name                 = var.registry_name
  sku                           = var.acr_sku
  admin_enabled                 = var.acr_admin_enabled
  georeplications               = var.acr_georeplications
  network_rule_bypass_option    = var.acr_network_rule_bypass_option
  public_network_access_enabled = var.acr_public_network_access_enabled
  aks_principal_id              = module.aks.kubelet_identity_principal_id
  enable_aks_push               = var.enable_aks_push_to_acr
  tags                          = local.common_tags

  depends_on = [module.aks]
}
