# Cost-Optimized AKS with Terraform

Production-grade, modular Terraform configuration for **cheapest possible Azure Kubernetes Service (AKS)** deployment with networking and authentication.

## Cost Optimization Details

This configuration is designed for **minimum Azure costs** while maintaining a functional Kubernetes cluster:

| Component | Cost-Saving Measure |
|-----------|-------------------|
| **Compute** | 1 node (minimum required) + Standard_B1s VM (cheapest tier) |
| **Add-ons** | HTTP application routing & Azure Policy disabled |
| **Networking** | Minimal NSG rules (443 only), efficient IP ranges (/16 VNet, /24 subnet) |
| **Service Principal** | Shared authentication for all infrastructure |

**Estimated Monthly Cost**: ~$20-30 USD (varies by region)

## Architecture

```
Resource Group
├── Virtual Network (10.0.0.0/16)
│   └── AKS Subnet (10.0.1.0/24)
│       └── NSG (HTTPS only)
├── Service Principal (AKS authentication)
└── AKS Cluster (1 x Standard_B1s node)
    └── Default Node Pool (managed by AKS)
```

## Prerequisites

1. **Terraform** >= 1.0
2. **Azure CLI** installed and authenticated:
   ```bash
   az login
   ```
3. **Azure Subscription** with permissions to create:
   - Resource Groups
   - Virtual Networks
   - AKS Clusters
   - Service Principals

## Quick Start

### 1. Initialize Terraform
```bash
cd ghtestrepo
terraform init
```

### 2. Plan Deployment
```bash
terraform plan -out=tfplan
```

### 3. Apply Configuration
```bash
terraform apply tfplan
```

### 4. Access Kubernetes Cluster
```bash
# Export kubeconfig
terraform output -raw aks_kube_config > ~/.kube/config
chmod 600 ~/.kube/config

# Verify cluster
kubectl get nodes
kubectl get pods --all-namespaces
```

## Configuration Files

### Root Module (`/`)

| File | Purpose |
|------|---------|
| **main.tf** | Resource Group + Service Principal + Module calls |
| **providers.tf** | Terraform and provider configuration |
| **variables.tf** | 40+ input variables (all cost-optimized) |
| **outputs.tf** | Cluster details for integration |
| **locals.tf** | Common tagging |

### Networking Module (`/modules/networking/`)

| File | Purpose |
|------|---------|
| **main.tf** | VNet, subnets, NSG (minimal rules) |
| **variables.tf** | Network configuration inputs |
| **outputs.tf** | VNet/NSG IDs for AKS module |

### AKS Module (`/modules/aks/`)

| File | Purpose |
|------|---------|
| **main.tf** | AKS cluster + default node pool |
| **variables.tf** | Cluster configuration inputs |
| **outputs.tf** | Cluster FQDN, kubeconfig, etc. |

## Variables Reference

### Resource Group (Root)
```hcl
resource_group_name = "rg-ghtestrepo"        # Azure RG name
resource_group_location = "westeurope"       # Azure region
environment = "dev"                          # dev/staging/prod
```

### Networking
```hcl
vnet_name = "vnet-aks"                       # Virtual network name
address_space = ["10.0.0.0/16"]              # VNet address space
aks_subnet_prefix = ["10.0.1.0/24"]          # Subnet for AKS nodes
```

### AKS Cluster (Cost-Optimized)
```hcl
cluster_name = "aks-cluster"                 # Cluster name
default_node_pool_count = 1                  # Minimum nodes
default_node_pool_vm_size = "Standard_B1s"   # Cheapest tier VM
enable_http_application_routing = false      # Save costs
enable_azure_policy = false                  # Save costs
```

## Outputs

```bash
# Get all outputs
terraform output

# Key outputs:
terraform output -raw aks_kube_config        # Kubeconfig (sensitive)
terraform output aks_cluster_name            # Cluster name
terraform output aks_fqdn                    # Cluster FQDN
terraform output aks_node_resource_group     # Node RG name
```

## Cost Analysis

### Current Configuration (~$25/month)
- **AKS Cluster**: ~$0.10/day (free tier includes Kubernetes management)
- **1x Standard_B1s VM**: ~$7/month
- **Data transfer**: ~$5/month (typical usage)
- **Storage (OS disks)**: ~$10/month

### Potential Upgrades
| Change | Cost Impact |
|--------|------------|
| Add 1 node (2 total) | +$7/month |
| Change to Standard_B2s | +$15/month |
| Enable HTTP routing | +$2/month |
| Add Spot instance (1 node) | ~$2-3/month (70% cheaper) |

## Manage Cluster

### Scale Up
```bash
terraform apply -var="default_node_pool_count=2"
```

### Change VM Size
```bash
terraform apply -var="default_node_pool_vm_size=Standard_B2s"
```

### Enable Add-ons
```bash
terraform apply \
  -var="enable_http_application_routing=true" \
  -var="enable_azure_policy=true"
```

### Add GPU Node Pool (Advanced)
```hcl
# In terraform.tfvars or variables
additional_node_pools = {
  gpu = {
    name = "gpu"
    node_count = 1
    vm_size = "Standard_NC6"
  }
}
```

## Troubleshooting

### Module Not Found
```bash
terraform init -upgrade
```

### Authentication Fails
```bash
az logout
az login
terraform plan -refresh=true
```

### Insufficient Quota
Check Azure subscription limits at:
https://portal.azure.com/#view/Microsoft_Azure_Capacity/QuotaBladeTemplate

## Cleanup

**Destroy all resources:**
```bash
terraform destroy
```

## Best Practices

✅ Use `terraform plan` before `terraform apply`  
✅ Keep kubeconfig in `.gitignore` (already done)  
✅ Regularly update Terraform state  
✅ Monitor Azure costs in Cost Management portal  
✅ Use resource tags for cost allocation  
✅ Set spending limits in Azure subscription  

## Support & Documentation

- **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/azurerm
- **AKS Pricing**: https://azure.microsoft.com/en-us/pricing/details/kubernetes-service/
- **Azure CLI**: https://learn.microsoft.com/en-us/cli/azure/

## License

This configuration is provided as-is for educational and commercial use.

## Variables

- `resource_group_name` (optional, default: "rg-terraform-demo") - Name of the resource group
- `resource_group_location` (optional, default: "westus") - Azure region (must be valid Azure location)
- `environment` (optional, default: "dev") - Environment name (dev, staging, or prod)
- `common_tags` (optional) - Common tags to apply to all resources

## Outputs

- `resource_group_id` - The ID of the created resource group
- `resource_group_name` - The name of the created resource group
- `resource_group_location` - The location of the created resource group

## Destroying Resources

To delete the resource group and all resources:
```bash
terraform destroy
```

## Using Azure Storage Backend (Optional)

To use an Azure Storage Account instead of local state, uncomment the `backend "azurerm"` block in main.tf and update with your storage account details.

## Authentication

This configuration uses Azure CLI authentication. Ensure you're logged in:
```bash
az login
# or for service principal:
az login --service-principal -u <APP_ID> -p <PASSWORD> --tenant <TENANT_ID>
```

## Troubleshooting

- **"Authentication could not be resolved"**: Run `az login` to authenticate with Azure
- **"ResourceGroupAlreadyExists"**: Change `resource_group_name` to a unique value
- **"InvalidLocation"**: Verify location is a valid Azure region using `az account list-locations`

## Documentation

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Resource Group Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
