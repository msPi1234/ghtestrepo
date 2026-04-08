variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-ghtestrepo"

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90 && can(regex("^[a-zA-Z0-9._()-]+$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters and contain only alphanumeric characters, hyphens, underscores, periods, and parentheses."
  }
}

variable "resource_group_location" {
  description = "The Azure region where the resource group will be created"
  type        = string
  default     = "westeurope"

  validation {
    condition     = can(regex("^[a-z0-9]+$", replace(var.resource_group_location, " ", "")))
    error_message = "Location must be a valid Azure region."
  }
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project = "Terraform-Demo"
    Owner   = "Infrastructure"
  }
}

# Networking Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-aks"
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"] # Smaller, more efficient
}

variable "aks_subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
  default     = "subnet-aks"
}

variable "aks_subnet_prefix" {
  description = "Address prefix for AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"] # Smaller subnet
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-aks"
}

# AKS Variables
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-cluster"

  validation {
    condition     = length(var.cluster_name) >= 1 && length(var.cluster_name) <= 63 && can(regex("^[a-zA-Z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must be 1-63 characters long and contain only alphanumeric characters and hyphens."
  }
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use (leave null for latest)"
  type        = string
  default     = null
}

variable "default_node_pool_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1 # Minimum = cheapest

  validation {
    condition     = var.default_node_pool_count >= 1 && var.default_node_pool_count <= 100
    error_message = "Node count must be between 1 and 100."
  }
}

variable "default_node_pool_vm_size" {
  description = "VM size for nodes in the default pool"
  type        = string
  default     = "Standard_B2s" # Minimum size for AKS system node pool (2 cores, 4GB RAM)
}

variable "network_plugin" {
  description = "Network plugin to use (azure or kubenet)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  description = "Network policy to use (azure or calico)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be either 'azure' or 'calico'."
  }
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.240.0.0/16" # Non-overlapping with node subnet 10.0.1.0/24

  validation {
    condition     = can(cidrhost(var.service_cidr, 0))
    error_message = "Service CIDR must be a valid CIDR block."
  }
}

variable "dns_service_ip" {
  description = "IP address for DNS service"
  type        = string
  default     = "10.240.0.10" # Must be within service CIDR range
}

variable "enable_http_application_routing" {
  description = "Enable HTTP application routing"
  type        = bool
  default     = false # Disabled to save costs
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy for AKS"
  type        = bool
  default     = false # Disabled to save costs
}

# ============================================================================
# ACR (Azure Container Registry) Variables
# ============================================================================

variable "registry_name" {
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)"
  type        = string
  default     = "ghtestreporegistry" # Change to your unique name

  validation {
    condition     = length(var.registry_name) >= 5 && length(var.registry_name) <= 50 && can(regex("^[a-z0-9]+$", var.registry_name))
    error_message = "Registry name must be 5-50 characters, lowercase alphanumeric only, and globally unique."
  }
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry (Basic, Standard, Premium)"
  type        = string
  default     = "Basic" # Cheapest tier - ideal for cost optimization

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Enable admin user for container registry"
  type        = bool
  default     = false # Security best practice - use RBAC instead
}

variable "acr_georeplications" {
  description = "List of geo-replication configurations for high availability"
  type = list(object({
    location                  = string
    zone_redundancy_enabled   = optional(bool, false)
    regional_endpoint_enabled = optional(bool, false)
  }))
  default = [] # No geo-replication by default (cost optimization)
}

variable "acr_network_rule_bypass_option" {
  description = "Whether to allow bypass of network rules (AzureServices, None)"
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.acr_network_rule_bypass_option)
    error_message = "Must be either AzureServices or None."
  }
}

variable "acr_public_network_access_enabled" {
  description = "Whether public network access is allowed for the registry"
  type        = bool
  default     = true # Allow public access (restrict via network rules if needed)
}

variable "enable_aks_push_to_acr" {
  description = "Enable AKS cluster to push images to ACR (AcrPush role)"
  type        = bool
  default     = false # Read-only by default for security
}
