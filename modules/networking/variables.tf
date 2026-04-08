variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-aks"
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/8"]

  validation {
    condition     = alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "Address space must contain valid CIDR blocks."
  }
}

variable "aks_subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
  default     = "subnet-aks"
}

variable "aks_subnet_prefix" {
  description = "Address prefix for AKS subnet"
  type        = list(string)
  default     = ["10.1.0.0/16"]

  validation {
    condition     = alltrue([for cidr in var.aks_subnet_prefix : can(cidrhost(cidr, 0))])
    error_message = "Subnet prefix must contain valid CIDR blocks."
  }
}

variable "additional_subnets" {
  description = "Additional subnets to create"
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = {}
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-aks"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
