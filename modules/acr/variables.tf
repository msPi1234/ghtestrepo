variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the container registry"
  type        = string
}

variable "registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string

  validation {
    condition     = length(var.registry_name) >= 5 && length(var.registry_name) <= 50 && can(regex("^[a-z0-9]+$", var.registry_name))
    error_message = "Registry name must be 5-50 characters, lowercase alphanumeric only, and globally unique."
  }
}

variable "sku" {
  description = "The SKU of the container registry (Basic, Standard, Premium)"
  type        = string
  default     = "Basic" # Cheapest tier for cost optimization

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for the registry"
  type        = bool
  default     = false # Security best practice - use RBAC instead
}

variable "georeplications" {
  description = "List of geo-replication configurations"
  type = list(object({
    location                  = string
    zone_redundancy_enabled   = optional(bool, false)
    regional_endpoint_enabled = optional(bool, false)
  }))
  default = [] # No geo-replication by default (cost optimization)
}

variable "network_rule_bypass_option" {
  description = "Whether to allow bypass of network rules (AzureServices, None)"
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.network_rule_bypass_option)
    error_message = "Must be either AzureServices or None."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed"
  type        = bool
  default     = true # Allow public access for simplicity (can be restricted later)
}

variable "aks_principal_id" {
  description = "Principal ID of AKS cluster's kubelet identity for ACR pull"
  type        = string
}

variable "enable_aks_push" {
  description = "Enable AKS cluster to push images to ACR (AcrPush role)"
  type        = bool
  default     = false # Read-only by default for security
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
