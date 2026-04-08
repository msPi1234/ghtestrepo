# Jenkins Setup Guide - Complete Configuration

This guide provides step-by-step instructions to configure Jenkins for automated deployment.

## Prerequisites

- Jenkins 2.300+ running and accessible
- Docker installed and running on Jenkins agent
- kubectl installed on Jenkins agent
- Helm 3.x installed on Jenkins agent
- Azure CLI installed on Jenkins agent
- Git access to the repository

---

## Phase 1: Create Azure Service Principal

### Step 1: Create Service Principal
```bash
# Login to Azure
az login

# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name jenkins-aks-deployer \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>
```

**Output will look like:**
```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "jenkins-aks-deployer",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### Step 2: Get Additional Required Values
```bash
# Subscription ID
az account show --query id -o tsv
# Output: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Tenant ID  
az account show --query tenantId -o tsv
# Output: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

**Save these values:**
- appId = AZURE_CLIENT_ID
- password = AZURE_CLIENT_SECRET
- tenant = AZURE_TENANT_ID
- subscription = AZURE_SUBSCRIPTION_ID

---

## Phase 2: Configure Jenkins Credentials

### Step 1: Open Jenkins Credentials Manager

1. Navigate to **Manage Jenkins** → **Manage Credentials**
2. Click on **System** in the left sidebar
3. Click on **Global credentials (unrestricted)**

### Step 2: Add Azure Subscription ID

1. Click **+ Add Credentials**
2. **Kind**: Secret text
3. **Secret**: `<AZURE_SUBSCRIPTION_ID>` (from above)
4. **ID**: `azure-subscription-id`
5. **Description**: Azure Subscription ID
6. Click **Create**

### Step 3: Add Azure Tenant ID

1. Click **+ Add Credentials**
2. **Kind**: Secret text
3. **Secret**: `<AZURE_TENANT_ID>` (from above)
4. **ID**: `azure-tenant-id`
5. **Description**: Azure AD Tenant ID
6. Click **Create**

### Step 4: Add Azure Client ID

1. Click **+ Add Credentials**
2. **Kind**: Secret text
3. **Secret**: `<AZURE_CLIENT_ID>` (appId from above)
4. **ID**: `azure-client-id`
5. **Description**: Azure Service Principal Client ID
6. Click **Create**

### Step 5: Add Azure Client Secret

1. Click **+ Add Credentials**
2. **Kind**: Secret text
3. **Secret**: `<AZURE_CLIENT_SECRET>` (password from above)
4. **ID**: `azure-client-secret`
5. **Description**: Azure Service Principal Client Secret
6. Click **Create**

**Verify all credentials are saved:**
- ✓ azure-subscription-id
- ✓ azure-tenant-id
- ✓ azure-client-id
- ✓ azure-client-secret

---

## Phase 3: Configure Jenkins Agent

### Check Required Tools

SSH into your Jenkins agent and verify:

```bash
# Docker
docker --version
# Output: Docker version 20.x.x

# kubectl
kubectl version --client
# Output: Client Version: v1.x.x

# Helm
helm version --short
# Output: v3.x.x

# Azure CLI
az --version
# Output: azure-cli x.x.x
```

### Install Missing Tools (if needed)

**Docker:**
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install docker.io -y

# RHEL/CentOS
sudo yum install docker -y

# Add Jenkins user to docker group
sudo usermod -aG docker jenkins
```

**kubectl:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**Helm:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**Azure CLI:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

## Phase 4: Create Jenkins Pipeline Job

### Step 1: Create New Pipeline Job

1. Jenkins Dashboard → **New Item**
2. **Enter item name**: `hello-world-aks-deployment`
3. **Select**: Pipeline
4. Click **OK**

### Step 2: Configure General Settings

**General Tab:**
- ✓ Enable: **This project is parameterized**

Add these parameters:

| Parameter Name | Type | Default Value |
|---|---|---|
| IMAGE_TAG | String | latest |
| HELM_RELEASE_NAME | String | hello-world |
| KUBE_NAMESPACE | String | default |

### Step 3: Configure Pipeline

**Pipeline Tab:**
- **Definition**: Pipeline script from SCM
- **SCM**: Git
  - **Repository URL**: `https://github.com/<YOUR-REPO>/ghtestrepo.git`
  - **Credentials**: (select or add GitHub credentials if private repo)
  - **Branch Specifier**: `*/main`
  - **Repository browser**: GitHub
  - **Script Path**: `Jenkinsfile`

### Step 4: Advanced Options (Optional)

**Pipeline Tab** → **Additional Behaviors:**
- ✓ Check out to a sub-directory: `source`
- ✓ Clean before checkout

### Step 5: Configure Build Triggers

**Build Triggers Tab:**

Option A: **GitHub hook trigger for GITscm polling** (requires GitHub webhook)
- Configure webhook in GitHub: `https://your-jenkins.com/github-webhook/`

Option B: **Poll SCM** (if no webhook available)
- **Schedule**: `H H * * *` (daily at midnight)

### Step 6: Save Configuration

Click **Save**

---

## Phase 5: Configure Jenkins Node

### Step 1: Configure Node Labels

Jenkins Dashboard → **Manage Jenkins** → **Manage Nodes and Clouds**

Select your node and configure:
- **Labels**: `docker kubernetes helm azure`
- **Usage**: Utilize this node only for jobs matching labels

### Step 2: Update Jenkinsfile Node Requirements

If using a different node name, update the Jenkinsfile:

```groovy
// Change this line in Jenkinsfile
agent any

// To:
agent {
    label 'docker && kubernetes'
}
```

---

## Phase 6: Test Pipeline Execution

### First Test Run

1. Jenkins Dashboard → Select job **hello-world-aks-deployment**
2. Click **Build with Parameters**
3. Keep default parameters:
   - IMAGE_TAG: `latest`
   - HELM_RELEASE_NAME: `hello-world`
   - KUBE_NAMESPACE: `default`
4. Click **Build**

### Monitor Execution

1. Watch console output in real-time
2. Expected stages: Build → Test → Login → Push → Deploy → Verify → Smoke Test
3. Check for any errors in red text

### Review Output

Successful pipeline should show:
```
✅ - Build Docker image succeeded
✅ - Image tests passed
✅ - Pushed to ACR: ghtestreporegistry.azurecr.io/hello-world:latest
✅ - Deployment verified with Helm
✅ - Kubernetes deployment complete
```

### Verify Deployment in AKS

```bash
# SSH to Jenkins agent
az aks get-credentials \
  --resource-group rg-ghtestrepo \
  --name aks-cluster

# Check pods
kubectl get pods -n default -l app.kubernetes.io/name=hello-world

# Get service IP
kubectl get svc hello-world -n default
```

---

## Phase 7: Test GitHub Integration (Optional)

### Set Up GitHub Webhook

1. Open GitHub repository
2. Go to **Settings** → **Webhooks** → **Add webhook**
3. **Payload URL**: `https://your-jenkins.com/github-webhook/`
4. **Content type**: application/json
5. **Events**: Push events
6. Click **Add webhook**

### Test Webhook

1. Make a code change to the repository
2. Push to main branch: `git push origin main`
3. Jenkins should automatically trigger pipeline
4. Monitor build progress

---

## Phase 8: Troubleshooting Common Issues

### Issue: Azure Authentication Failed

**Error**: `Error: authentication required`

**Solution**:
```bash
# Verify credentials in Jenkins
# Manually test on Jenkins agent:
az login --service-principal \
  -u <AZURE_CLIENT_ID> \
  -p <AZURE_CLIENT_SECRET> \
  --tenant <AZURE_TENANT_ID>
```

### Issue: Docker Image Build Fails

**Error**: `COPY failed: file not found`

**Solution**:
```bash
# Check working directory in Jenkinsfile
# app/ directory must exist in repository

# Verify:
ls -la app/
# Should show: Dockerfile, package.json, server.js
```

### Issue: kubectl Connection Failed

**Error**: `Unable to connect to the server`

**Solution**:
```bash
# Verify AKS credentials
az aks get-credentials \
  --resource-group rg-ghtestrepo \
  --name aks-cluster

# Test connection
kubectl cluster-info
```

### Issue: Helm Deployment Timeout

**Error**: `error waiting for deployment/hello-world to rollout`

**Solution**:
```bash
# Check pod status
kubectl get pods -n default

# View pod logs
kubectl logs -n default -l app.kubernetes.io/name=hello-world

# Check image pull
kubectl describe pod <POD_NAME> -n default
```

### Issue: ACR Access Denied

**Error**: `Error response from daemon: unauthorized`

**Solution**:
```bash
# Verify ACR credentials
az acr credential show \
  --name ghtestreporegistry \
  --resource-group rg-ghtestrepo

# Check role assignment
az role assignment list \
  --assignee <AZURE_CLIENT_ID> \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-ghtestrepo
```

---

## Phase 9: Production Configurations

### Enable Build Timeout

1. Job → **Configure**
2. **Build Environment** → Enable **Abort the build if it's stuck**
3. **Timeout**: 30 minutes

### Enable Build Retention

1. Job → **Configure**
2. **General** → Enable **Discard old builds**
3. **Max builds to keep**: 30
4. **Max builds to keep with artifacts**: 10

### Enable Build Notifications

1. Job → **Configure**
2. **Post-build Actions** → Add **Email Notification**
3. **Recipients**: `team@example.com`
4. **Send if build is unstable**: ✓

### Enable Pipeline Logging

1. Job → **Configure**
2. **Logging** → Set **Log Level**: INFO

---

## Phase 10: Advanced Configuration

### Use Custom Docker Registry

Update these in Jenkinsfile if using different registry:

```groovy
environment {
    ACR_REGISTRY = 'your-registry.azurecr.io'
    ACR_LOGIN_SERVER = 'your-registry.azurecr.io'
    IMAGE_NAME = "${ACR_LOGIN_SERVER}/hello-world"
}
```

### Use Different AKS Cluster

Update environment variables in Jenkinsfile:

```groovy
environment {
    AKS_RESOURCE_GROUP = 'your-rg'
    AKS_CLUSTER_NAME = 'your-cluster'
    AKS_REGION = 'eastus'
}
```

### Add Slack Notifications

1. Install Jenkins **Slack Plugin**
2. Configure Slack workspace and token
3. Add to Jenkinsfile:

```groovy
post {
    always {
        slackSend(
            channel: '#deployments',
            message: "Build ${BUILD_NUMBER} - ${currentBuild.result}",
            color: currentBuild.result == 'SUCCESS' ? 'good' : 'danger'
        )
    }
}
```

### Add Email Notifications

```groovy
post {
    failure {
        emailext(
            subject: "Pipeline failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            body: "Build ${env.BUILD_URL} failed",
            recipientProviders: [developers(), requestor()]
        )
    }
}
```

---

## Verification Checklist

Before running production builds, verify:

- [ ] All 4 Azure credentials configured in Jenkins
- [ ] Docker, kubectl, Helm installed on agent
- [ ] Jenkins job created and configured
- [ ] GitHub webhook (if using) configured and tested
- [ ] First test build completed successfully
- [ ] Application accessible at LoadBalancer IP
- [ ] Logs accessible via kubectl
- [ ] Helm chart deployed to AKS
- [ ] Auto-scaling configured and working

---

## Quick Reference

### Access Deployed App
```bash
LOAD_BALANCER_IP=$(kubectl get svc hello-world -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application URL: http://${LOAD_BALANCER_IP}"
```

### Monitor Application
```bash
kubectl logs -f deployment/hello-world -n default
```

### Scale Application
```bash
kubectl scale deployment hello-world -n default --replicas=4
```

### Update Application
```bash
git commit -m "Update app" && git push origin main
# Jenkins automatically triggers deployment
```

---

## Support & Troubleshooting

For detailed troubleshooting:
- See [DEPLOYMENT.md](DEPLOYMENT.md) - Full deployment guide
- See [QUICKSTART.md](QUICKSTART.md) - Quick command reference
- Jenkins logs: Jenkins Dashboard → Build → Console Output
- Application logs: `kubectl logs -f pod/<POD_NAME> -n default`
- Check AKS events: `kubectl get events -n default --sort-by='.lastTimestamp'`

---

**Last Updated**: April 2026
**Version**: 1.0
