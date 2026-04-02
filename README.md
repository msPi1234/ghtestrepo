# ==========================================
# Terraform AKS Azure Production Example Repo
# ==========================================

# Structure:
# .
# ├── main.tf
# ├── variables.tf
# ├── outputs.tf
# ├── providers.tf
# ├── backend.tf
# ├── modules/
# │   ├── network/
# │   ├── aks/
# │   └── acr/
# └── k8s/
#     ├── deployment.yaml
#     └── service.yaml