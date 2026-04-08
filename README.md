# Azure Resource Group Terraform Configuration

This Terraform configuration creates an Azure Resource Group with all required dependencies.

## Prerequisites

1. Terraform >= 1.0
2. Azure CLI installed and authenticated (`az login`)
3. Appropriate Azure permissions to create resource groups

## Quick Start

1. **Initialize Terraform** (downloads providers and initializes backend):
   ```bash
   terraform init
   ```

2. **Copy and customize variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired values
   ```

3. **Plan the deployment** (preview changes):
   ```bash
   terraform plan
   ```

4. **Apply the configuration** (create resources):
   ```bash
   terraform apply
   ```

5. **View outputs** (retrieve created resource details):
   ```bash
   terraform output
   ```

## Configuration Files

- **main.tf** - Contains:
  - Terraform version and provider requirements
  - Azure provider configuration
  - Resource Group resource definition
  - Input variables with validation
  - Output values

- **terraform.tfvars.example** - Example variables file (copy to `terraform.tfvars` and customize)

- **.gitignore** - Excludes sensitive files from version control

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
