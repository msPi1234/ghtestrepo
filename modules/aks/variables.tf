variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

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
  description = "Version of Kubernetes to use"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID of the subnet for the AKS cluster"
  type        = string
}

variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "default_node_pool_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1

  validation {
    condition     = var.default_node_pool_count >= 1 && var.default_node_pool_count <= 100
    error_message = "Node count must be between 1 and 100."
  }
}

variable "default_node_pool_vm_size" {
  description = "VM size for nodes in the default pool"
  type        = string
  default     = "Standard_B1s"
}

variable "client_id" {
  description = "Client ID of the Service Principal for AKS"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Client Secret of the Service Principal for AKS"
  type        = string
  sensitive   = true
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
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.service_cidr, 0))
    error_message = "Service CIDR must be a valid CIDR block."
  }
}

variable "dns_service_ip" {
  description = "IP address for DNS service"
  type        = string
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  description = "CIDR for Docker bridge (deprecated - will be removed in azurerm 4.0)"
  type        = string
  default     = "172.17.0.1/16"
}

variable "enable_http_application_routing" {
  description = "Enable HTTP application routing"
  type        = bool
  default     = false
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy for AKS"
  type        = bool
  default     = false
}

variable "additional_node_pools" {
  description = "Additional node pools to create"
  type = map(object({
    name       = string
    node_count = number
    vm_size    = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
