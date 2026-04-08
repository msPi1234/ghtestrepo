pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    parameters {
        string(
            name: 'IMAGE_TAG',
            defaultValue: 'latest',
            description: 'Docker image tag for deployment'
        )
        string(
            name: 'HELM_RELEASE_NAME',
            defaultValue: 'hello-world',
            description: 'Helm release name'
        )
        string(
            name: 'KUBE_NAMESPACE',
            defaultValue: 'default',
            description: 'Kubernetes namespace for deployment'
        )
    }

    environment {
        // Azure Configuration
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        AZURE_CLIENT_ID = credentials('azure-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        
        // ACR Configuration
        ACR_REGISTRY = 'ghtestreporegistry.azurecr.io'
        ACR_LOGIN_SERVER = 'ghtestreporegistry.azurecr.io'
        IMAGE_NAME = "${ACR_LOGIN_SERVER}/hello-world"
        IMAGE_TAG_FULL = "${IMAGE_NAME}:${params.IMAGE_TAG}"
        
        // AKS Configuration
        AKS_RESOURCE_GROUP = 'rg-ghtestrepo'
        AKS_CLUSTER_NAME = 'aks-cluster'
        AKS_REGION = 'westeurope'
        
        // Build metadata
        BUILD_TIMESTAMP = sh(script: "date -u +'%Y%m%d-%H%M%S'", returnStdout: true).trim()
        GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out source code..."
                    checkout scm
                    echo "Repository checked out successfully"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_TAG_FULL}"
                    dir('app') {
                        sh '''
                            docker build \
                                --tag ${IMAGE_TAG_FULL} \
                                --tag ${IMAGE_NAME}:${BUILD_TIMESTAMP} \
                                --tag ${IMAGE_NAME}:${GIT_COMMIT_SHORT} \
                                --label git.commit=${GIT_COMMIT_SHORT} \
                                --label build.timestamp=${BUILD_TIMESTAMP} \
                                --label build.number=${BUILD_NUMBER} \
                                --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                                --build-arg VCS_REF=${GIT_COMMIT_SHORT} \
                                .
                            docker images | grep hello-world
                        '''
                    }
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    echo "Running Docker health check..."
                    sh '''
                        # Start container
                        CONTAINER_ID=$(docker run -d -p 3000:3000 ${IMAGE_TAG_FULL})
                        echo "Container started: ${CONTAINER_ID}"
                        
                        # Wait for service to start
                        sleep 5
                        
                        # Test endpoints
                        echo "Testing health endpoint..."
                        curl -f http://localhost:3000/health || exit 1
                        
                        echo "Testing ready endpoint..."
                        curl -f http://localhost:3000/ready || exit 1
                        
                        echo "Testing root endpoint..."
                        curl -f http://localhost:3000/ > /dev/null || exit 1
                        
                        # Stop container
                        docker stop ${CONTAINER_ID}
                        docker rm ${CONTAINER_ID}
                        
                        echo "Docker image tests passed!"
                    '''
                }
            }
        }

        stage('Login to ACR') {
            steps {
                script {
                    echo "Authenticating with Azure Container Registry..."
                    sh '''
                        # Login to Azure using service principal
                        az login \
                            --service-principal \
                            -u ${AZURE_CLIENT_ID} \
                            -p ${AZURE_CLIENT_SECRET} \
                            --tenant ${AZURE_TENANT_ID}
                        
                        # Get ACR credentials
                        ACR_PASSWORD=$(az acr credential show \
                            --name ghtestreporegistry \
                            --resource-group ${AKS_RESOURCE_GROUP} \
                            --query passwords[0].value -o tsv)
                        
                        # Login to Docker registry
                        echo ${ACR_PASSWORD} | docker login \
                            -u ghtestreporegistry \
                            --password-stdin \
                            ${ACR_LOGIN_SERVER}
                        
                        echo "ACR authentication successful"
                    '''
                }
            }
        }

        stage('Push to ACR') {
            steps {
                script {
                    echo "Pushing Docker image to ACR..."
                    sh '''
                        docker push ${IMAGE_TAG_FULL}
                        docker push ${IMAGE_NAME}:${BUILD_TIMESTAMP}
                        docker push ${IMAGE_NAME}:${GIT_COMMIT_SHORT}
                        
                        echo "Images pushed successfully to ${ACR_LOGIN_SERVER}"
                    '''
                }
            }
        }

        stage('Get AKS Credentials') {
            steps {
                script {
                    echo "Getting AKS cluster credentials..."
                    sh '''
                        az aks get-credentials \
                            --resource-group ${AKS_RESOURCE_GROUP} \
                            --name ${AKS_CLUSTER_NAME} \
                            --overwrite-existing
                        
                        # Verify cluster access
                        kubectl cluster-info
                        kubectl get nodes
                    '''
                }
            }
        }

        stage('Create Namespace') {
            steps {
                script {
                    echo "Creating/verifying Kubernetes namespace..."
                    sh '''
                        kubectl create namespace ${KUBE_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                        echo "Namespace ${KUBE_NAMESPACE} ready"
                    '''
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                script {
                    echo "Deploying application with Helm..."
                    sh '''
                        cd helm/hello-world
                        
                        # Lint Helm chart
                        helm lint .
                        
                        # Add/update Helm repository (if using external charts)
                        # helm repo add myrepo https://example.com/charts
                        # helm repo update
                        
                        # Deploy or upgrade Helm release
                        helm upgrade --install ${HELM_RELEASE_NAME} . \
                            --namespace ${KUBE_NAMESPACE} \
                            --create-namespace \
                            --values values.yaml \
                            --set image.repository=${IMAGE_NAME} \
                            --set image.tag=${params.IMAGE_TAG} \
                            --set replicaCount=2 \
                            --set autoscaling.enabled=true \
                            --wait \
                            --timeout 5m \
                            --debug
                        
                        echo "Helm deployment completed"
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Verifying deployment status..."
                    sh '''
                        # Check pod status
                        kubectl get pods -n ${KUBE_NAMESPACE} -l app.kubernetes.io/name=hello-world
                        
                        # Wait for deployment to be ready
                        kubectl rollout status deployment/hello-world \
                            -n ${KUBE_NAMESPACE} \
                            --timeout=5m
                        
                        # Get service details
                        kubectl get svc -n ${KUBE_NAMESPACE}
                        
                        # Display deployment info
                        kubectl describe deployment hello-world -n ${KUBE_NAMESPACE}
                        
                        echo "Deployment verification completed"
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    echo "Running smoke tests on deployed application..."
                    sh '''
                        # Get service endpoint
                        SERVICE_IP=$(kubectl get svc hello-world \
                            -n ${KUBE_NAMESPACE} \
                            -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                        
                        if [ -z "${SERVICE_IP}" ]; then
                            echo "Service IP not yet assigned, retrying..."
                            sleep 30
                            SERVICE_IP=$(kubectl get svc hello-world \
                                -n ${KUBE_NAMESPACE} \
                                -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                        fi
                        
                        if [ -z "${SERVICE_IP}" ]; then
                            echo "Warning: Could not get LoadBalancer IP. Service may still be provisioning."
                            echo "You can manually test with: kubectl port-forward svc/hello-world 3000:80 -n ${KUBE_NAMESPACE}"
                        else
                            echo "Testing application at http://${SERVICE_IP}..."
                            curl -v http://${SERVICE_IP}/health || true
                            curl -v http://${SERVICE_IP}/ || true
                        fi
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Pipeline execution completed"
                sh '''
                    # Clean up Docker images locally to save space
                    docker image prune -f --filter "until=24h"
                    
                    # Display final status
                    kubectl get all -n ${KUBE_NAMESPACE} || true
                '''
            }
        }
        success {
            script {
                echo "✅ Pipeline completed successfully!"
                echo "Deployment Details:"
                echo "  - Image: ${IMAGE_TAG_FULL}"
                echo "  - Release: ${HELM_RELEASE_NAME}"
                echo "  - Namespace: ${KUBE_NAMESPACE}"
                echo "  - Cluster: ${AKS_CLUSTER_NAME}"
            }
        }
        failure {
            script {
                echo "❌ Pipeline failed. Check logs above for details."
                sh '''
                    echo "Recent pod events:"
                    kubectl get events -n ${KUBE_NAMESPACE} --sort-by='.lastTimestamp' | tail -20 || true
                '''
            }
        }
        unstable {
            echo "⚠️  Pipeline is unstable. Some tests may have failed."
        }
    }
}
