# Quick Start Guide

## 5-Minute Setup

### Prerequisites
Ensure you have:
- Azure CLI installed and authenticated
- kubectl configured for AKS access
- Helm 3.x installed
- Git access to this repository

### Step 1: Get AKS Credentials (30 seconds)
```bash
az aks get-credentials \
  --resource-group rg-ghtestrepo \
  --name aks-cluster
```

### Step 2: Deploy with Helm (1 minute)
```bash
helm install hello-world helm/hello-world/ \
  --namespace default \
  --create-namespace
```

### Step 3: Get Application URL (1 minute)
```bash
kubectl get svc hello-world -n default -w
```
Wait for external IP, then open in browser: `http://<EXTERNAL_IP>`

### Step 4: View Logs (30 seconds)
```bash
kubectl logs -l app.kubernetes.io/name=hello-world -n default -f
```

---

## Common Commands

### Check Status
```bash
# Pods
kubectl get pods -n default

# Deployments
kubectl get deployment hello-world -n default

# Services
kubectl get svc hello-world -n default

# All resources
kubectl get all -n default -l app.kubernetes.io/name=hello-world
```

### Scale
```bash
# To 3 replicas
kubectl scale deployment hello-world -n default --replicas=3

# View HPA status
kubectl get hpa -n default
```

### Update Image
```bash
helm upgrade hello-world helm/hello-world/ \
  --set image.tag=v1.0.1 \
  -n default
```

### Rollback
```bash
helm rollback hello-world -n default
```

### Debug
```bash
# Describe pod
kubectl describe pod <POD_NAME> -n default

# View logs
kubectl logs <POD_NAME> -n default -f

# Execute command in pod
kubectl exec -it <POD_NAME> -n default -- sh

# Port forward for testing
kubectl port-forward svc/hello-world 3000:80 -n default
```

### Cleanup
```bash
helm uninstall hello-world -n default
```

---

## Development Deployment

For development with single replica and lower resource limits:

```bash
helm install hello-world helm/hello-world/ \
  --namespace dev \
  --create-namespace \
  --values helm/hello-world/values-dev.yaml
```

---

## Jenkins Pipeline Trigger

Push to main branch to trigger automatic deployment:

```bash
git add .
git commit -m "Update application"
git push origin main
```

Jenkins will automatically:
1. Build Docker image
2. Push to ACR
3. Deploy to AKS using Helm
4. Run smoke tests

---

## Testing Endpoints

Once deployed, test these endpoints:

```bash
# Health check
curl http://<EXTERNAL_IP>/health

# Readiness check
curl http://<EXTERNAL_IP>/ready

# Main application
curl http://<EXTERNAL_IP>/
```

---

For detailed documentation, see [DEPLOYMENT.md](DEPLOYMENT.md)
