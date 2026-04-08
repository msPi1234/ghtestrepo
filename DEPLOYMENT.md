# Hello World Application - Jenkins CI/CD Pipeline

Complete Kubernetes deployment pipeline for a simple "Hello World" Node.js application using Jenkins, Docker, Azure Container Registry (ACR), and Azure Kubernetes Service (AKS) with Helm.

## Project Structure

```
├── app/
│   ├── server.js                 # Node.js Express app (Hello World)
│   ├── package.json              # NodJS dependencies
│   ├── Dockerfile                # Multi-stage Docker build
│   └── .dockerignore             # Docker build exclusions
├── helm/
│   └── hello-world/              # Helm chart for Kubernetes deployment
│       ├── Chart.yaml            # Helm chart metadata
│       ├── values.yaml           # Default configuration parameters
│       └── templates/
│           ├── _helpers.tpl      # Helm helper functions
│           ├── deployment.yaml   # Kubernetes Deployment
│           ├── service.yaml      # Kubernetes Service
│           ├── hpa.yaml          # Horizontal Pod Autoscaler
│           ├── pdb.yaml          # Pod Disruption Budget
│           ├── ingress.yaml      # Ingress configuration
│           └── serviceaccount.yaml # Service Account
├── Jenkinsfile                   # CI/CD pipeline definition
└── DEPLOYMENT.md                 # Deployment guide
```

## Architecture Overview

```
GitHub/Git Repository
        ↓
    Jenkins (CI/CD)
        ↓
  Build & Test (Docker)
        ↓
  Push to ACR (Azure Container Registry)
        ↓
  Deploy to AKS (Azure Kubernetes Service)
        ↓
   Helm Chart Deployment
        ↓
   Kubernetes Pods, Service, HPA
        ↓
   Application Available at LoadBalancer IP
```

## Features

### Application
- **Framework**: Express.js (Node.js)
- **Port**: 3000
- **Endpoints**:
  - `/` - Main Hello World page (HTML UI)
  - `/health` - Kubernetes liveness probe endpoint
  - `/ready` - Kubernetes readiness probe endpoint

### Docker
- Multi-stage build for optimized image size
- Non-root user for security
- Health checks included
- Alpine Linux base image for minimal footprint

### Helm
- **Replicas**: 2+ with autoscaling (2-4 pods)
- **Service**: LoadBalancer (public access)
- **Resource Limits**: CPU 500m, Memory 256Mi
- **Probes**: Liveness and Readiness configured
- **HPA**: Auto-scaling based on CPU and memory
- **Pod Disruption Budget**: Minimum 1 available pod

### Jenkins Pipeline Stages
1. **Checkout** - Clone repository
2. **Build Docker Image** - Build application image
3. **Test Docker Image** - Run health checks
4. **Login to ACR** - Authenticate with Azure Container Registry
5. **Push to ACR** - Upload image to registry
6. **Get AKS Credentials** - Configure kubectl access
7. **Create Namespace** - Prepare Kubernetes namespace
8. **Deploy with Helm** - Install/upgrade Helm release
9. **Verify Deployment** - Check pod status and rollout
10. **Smoke Test** - Validate application endpoints

## Prerequisites

### Azure Resources (Already Deployed)
- ✅ Azure Resource Group: `rg-ghtestrepo`
- ✅ Azure Container Registry (ACR): `ghtestreporegistry.azurecr.io`
- ✅ Azure Kubernetes Service (AKS): `aks-cluster`
- ✅ Virtual Network: `vnet-aks` (10.0.0.0/16)
- ✅ AKS subnet: `subnet-aks` (10.0.1.0/24)

### Local Tools Required
- Docker (for building/testing locally)
- kubectl (configured for AKS)
- Helm 3.x (for chart deployment)
- Azure CLI (for authentication)

### Jenkins Setup Required
- Jenkins server accessible and running
- Docker plugin/agent available
- Kubectl and Helm installed on Jenkins agents
- Azure CLI configured on Jenkins agents

## Jenkins Configuration

### 1. Create Jenkins Credentials

Store these in Jenkins Credentials (Manage Jenkins → Manage Credentials):

| Credential ID | Type | Description |
|---|---|---|
| `azure-subscription-id` | Secret text | Azure Subscription ID |
| `azure-tenant-id` | Secret text | Azure AD Tenant ID |
| `azure-client-id` | Secret text | Azure Service Principal Client ID |
| `azure-client-secret` | Secret text | Azure Service Principal Client Secret |

### 2. Get Credential Values

```bash
# From Azure CLI (requires owner permissions)
az account show --query id -o tsv  # Subscription ID
az account show --query tenantId -o tsv  # Tenant ID

# Service Principal (create if needed)
az ad sp create-for-rbac --name jenkins-aks-deployer \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}
```

### 3. Create Jenkins Pipeline Job

1. **New Item** → Select **Pipeline**
2. **Pipeline** section:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/yourrepo/ghtestrepo.git`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`
3. **Save** and run

### 4. Configure Build Parameters

In job configuration, enable these parameters:
- `IMAGE_TAG` (default: latest)
- `HELM_RELEASE_NAME` (default: hello-world)
- `KUBE_NAMESPACE` (default: default)

## Manual Deployment

### Option 1: Using Helm (Recommended)

```bash
# 1. Get AKS credentials
az aks get-credentials \
  --resource-group rg-ghtestrepo \
  --name aks-cluster

# 2. Verify cluster access
kubectl cluster-info
kubectl get nodes

# 3. Deploy with Helm
cd helm/hello-world

helm install hello-world . \
  --namespace default \
  --create-namespace \
  --values values.yaml \
  --set image.repository=ghtestreporegistry.azurecr.io/hello-world \
  --set image.tag=latest

# 4. Check deployment status
kubectl get deployments,pods,svc -n default

# 5. Get the LoadBalancer IP
kubectl get svc hello-world -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# 6. Access application
# Open browser to: http://<LOADBALANCER_IP>
```

### Option 2: Using kubectl directly

```bash
# Build and push image first
cd app
docker build -t ghtestreporegistry.azurecr.io/hello-world:latest .
docker push ghtestreporegistry.azurecr.io/hello-world:latest

# Then apply Helm templates
helm template hello-world helm/hello-world/ | kubectl apply -f -
```

## Local Testing

### Build and Test Locally

```bash
cd app

# Build image
docker build -t hello-world:test .

# Run container
docker run -d -p 3000:3000 --name hello-world-test hello-world:test

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/ready
curl http://localhost:3000/

# Stop container
docker stop hello-world-test
docker rm hello-world-test
```

### Test Helm Chart

```bash
cd helm/hello-world

# Validate chart
helm lint .

# Dry-run installation (see what would be applied)
helm install hello-world . \
  --values values.yaml \
  --dry-run \
  --debug

# Template the chart to see Kubernetes manifests
helm template hello-world . > manifests.yaml
cat manifests.yaml
```

## Monitoring and Troubleshooting

### Check Deployment Status

```bash
# Check pods
kubectl get pods -n default -l app.kubernetes.io/name=hello-world

# Check deployment
kubectl describe deployment hello-world -n default

# View logs
kubectl logs -n default -l app.kubernetes.io/name=hello-world -f

# Get specific pod logs
kubectl logs -n default hello-world-xxxx-yyyy -f

# Check service
kubectl get svc hello-world -n default
```

### Common Issues

| Issue | Resolution |
|---|---|
| Pod CrashLoopBackOff | Check logs: `kubectl logs <pod-name>` |
| Image pull errors | Verify ACR credentials and image repo URL |
| Service LoadBalancer IP pending | Wait 2-5 minutes for Azure to provision |
| Helm release conflict | Delete old release: `helm uninstall hello-world -n default` |
| Memory/CPU issues | Check resource requests/limits in values.yaml |

### Port Forward for Testing

If LoadBalancer IP is not available:

```bash
kubectl port-forward svc/hello-world 3000:80 -n default

# Then access at http://localhost:3000
```

## Scaling and Updates

### Scale Replicas

```bash
# Manual scaling
kubectl scale deployment hello-world -n default --replicas=3

# Using Helm
helm upgrade hello-world helm/hello-world/ \
  --set replicaCount=3 \
  -n default
```

### Update Application Image

```bash
# With new image tag
helm upgrade hello-world helm/hello-world/ \
  --set image.tag=v1.0.1 \
  -n default \
  --wait

# Check rollout status
kubectl rollout status deployment/hello-world -n default
```

### Rollback Deployment

```bash
# See release history
helm history hello-world -n default

# Rollback to previous release
helm rollback hello-world -n default
```

## Cleanup

### Delete Deployment

```bash
# Using Helm
helm uninstall hello-world -n default

# Verify deletion
kubectl get pods -n default
```

### Delete Entire Pipeline

```bash
# Jenkins: Delete job from UI
# Git: Delete repository or branch
# ACR: Delete image
az acr repository delete \
  --name ghtestreporegistry \
  --repository hello-world
```

## Environment Variables

The application uses these environment variables:

```
ENVIRONMENT=production  # Current environment
NODE_ENV=production     # Node.js environment
PORT=3000               # Server port (configurable)
```

## Security Considerations

✅ **Implemented**:
- Non-root container user (UID 1001)
- Read-only root filesystem option
- Pod security context restrictions
- Network security group (NSG) with minimal rules
- Service principal authentication for AKS

🔒 **Recommended Additional**:
- Enable pod security policies
- Use private AKS cluster
- Implement network policies
- Enable Azure Container Registry scanning
- Use sealed secrets for sensitive data
- Configure RBAC roles

## Performance Metrics

Expected performance (Standard_B2s node, 2 replicas):
- **Response time**: < 50ms
- **Container startup**: ~3-5 seconds
- **Memory per pod**: ~60-80MB
- **CPU per pod**: < 50m idle

## Contributing

To modify the application:

1. Update `app/server.js` for logic changes
2. Update `app/package.json` for dependencies
3. Update `Dockerfile` if needed
4. Test locally with Docker
5. Commit and push to trigger Jenkins pipeline
6. Monitor deployment in AKS

## References

- [Node.js Docker Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Azure AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [Jenkins Pipeline Documentation](https://jenkins.io/doc/book/pipeline/)

## Support

For issues or questions:
1. Check logs: `kubectl logs` and Jenkins build logs
2. Verify credentials and permissions in Jenkins
3. Ensure Azure resources are in correct state
4. Review this documentation for troubleshooting section
