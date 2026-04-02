# ==========================================
# modules/acr/main.tf
# ==========================================
resource "azurerm_container_registry" "acr" {
  name                = "myacr${random_integer.rand.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}

# modules/acr/variables.tf
variable "location" {}
variable "resource_group_name" {}