# ==========================================
# backend.tf
# ==========================================
terraform {
  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "tfstate12345"
    container_name       = "tfstate"
    key                  = "aks.tfstate"
  }
}