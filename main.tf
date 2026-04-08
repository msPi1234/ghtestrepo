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
