locals {
  common_tags = merge(
    var.common_tags,
    {
      CreatedBy   = "Terraform"
      Environment = var.environment
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}
