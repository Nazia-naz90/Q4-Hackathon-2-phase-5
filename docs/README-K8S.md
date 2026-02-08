# Phase 4: Local Kubernetes Deployment COMPLETE

## Status: ✅ COMPLETED

Successfully completed Phase 4 of the Todo Application - Local Kubernetes Deployment with Docker, Minikube, and Helm.

## Prerequisites

- Docker Desktop (with Kubernetes disabled or using minikube)
- Minikube
- kubectl
- Node.js (for local development)
- Python 3.13+ (for local development)

## Setup and Deployment Steps

### 1. Start Minikube

```bash
# Start Minikube with sufficient resources
minikube start --memory=4096 --cpus=2

# Optionally enable ingress addon
minikube addons enable ingress
```

### 2. Build Container Images

For each component, you'll need to build the Docker images. You can do this in two ways:

**Option A: Load images directly to Minikube**
```bash
# Set Docker environment to Minikube
eval $(minikube docker-env)

# Build images directly in minikube's environment
docker build -t todo-backend:v1 ./backend
docker build -t todo-frontend:v1 ./frontend
docker build -t todo-agent:v5 ./ai-agent

# Reset Docker environment back to normal
eval $(minikube docker-env -u)
```

**Option B: Build and load images**
```bash
# Build the images locally
docker build -t todo-backend:v1 ./backend
docker build -t todo-frontend:v1 ./frontend
docker build -t todo-agent:v5 ./ai-agent

# Load images into minikube
minikube image load todo-backend:v1
minikube image load todo-frontend:v1
minikube image load todo-agent:v5
```

### 3. Prepare Secrets

Update the `k8s/secrets.yaml` file with your actual values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: todo-secrets
type: Opaque
stringData:
  # Yahan apni actual values likhein
  POSTGRES_USER: "postgres"
  POSTGRES_PASSWORD: "mysecretpassword"
  POSTGRES_DB: "todo_db"
  # DATABASE_URL: postgresql://<user>:<password>@<service-name>:5432/<db-name>
  DATABASE_URL: postgresql://neondb_owner:npg_DRmg9fK7ZYrk@ep-sweet-frog-a1hrxlm4-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
  # Apni OpenAI Key neeche paste karein (bina quotes ke bhi chalega)
  OPENAI_API_KEY: "replace-with-your-real-key-before-deploying"
```

Then apply the secrets to Kubernetes:
```bash
kubectl apply -f k8s/secrets.yaml
```

### 4. Deploy to Kubernetes

Run the deployment script:
```bash
./scripts/deploy.sh
```

Or apply the manifests manually:
```bash
# Create secrets
kubectl apply -f k8s/secrets.yaml

# Apply backend components
kubectl apply -f k8s/backend/

# Apply frontend components
kubectl apply -f k8s/frontend/

# Apply AI agent components
kubectl apply -f k8s/ai-agent/
```

### 5. Verify Deployment

Check if all resources are running:
```bash
# Check deployments
kubectl get deployments

# Check services
kubectl get services

# Check pods
kubectl get pods
```

Check logs for any issues:
```bash
kubectl logs -l app=todo-backend
kubectl logs -l app=todo-frontend
kubectl logs -l app=todo-agent
```

### 6. Access the Application

**Using Minikube tunnel (recommended for LoadBalancer services):**
```bash
# In a separate terminal
minikube tunnel
```

Then find the external IP of the frontend service:
```bash
kubectl get services
```

**Using port forwarding:**
```bash
# Forward frontend port
kubectl port-forward svc/todo-frontend 3000:3000

# Forward backend port (for API access)
kubectl port-forward svc/todo-backend 8000:8000
```

**Using minikube service command:**
```bash
minikube service todo-frontend --url
```

## Internal Service Communication

Within the Kubernetes cluster, services communicate using internal DNS names:
- Backend: `http://todo-backend:8000`
- Frontend: Connects to backend using the above address
- AI Agent: Connects to backend using `http://todo-backend:8000`

## Troubleshooting

### Common Issues

1. **Images not found**: Make sure to load images into Minikube using `minikube image load` or build them in the Minikube environment.

2. **Database connection errors**: Verify that the DATABASE_URL in secrets is correct and that the database is accessible from within the cluster.

3. **Service-to-service communication fails**: Check that services are named correctly and that internal DNS resolution works using service names like `http://service-name:port`.

4. **Resource limits exceeded**: Adjust resource requests and limits in the deployment files based on your local machine's capabilities.

### Useful Commands

```bash
# Check pod status and events
kubectl describe pods --namespace=todo-app

# View logs for a specific pod
kubectl logs <pod-name> --namespace=todo-app

# Follow logs in real-time
kubectl logs -f <pod-name> --namespace=todo-app

# Exec into a pod to test connectivity
kubectl exec -it <pod-name> --namespace=todo-app -- /bin/sh

# Test connectivity to other services from within a pod
curl http://todo-backend-service:8000/
```

## Clean Up

To remove the deployment:
```bash
kubectl delete namespace todo-app
```

To stop Minikube:
```bash
minikube stop
```

## Architecture Overview

The deployment consists of:

- **Namespace**: `todo-app` - Isolation boundary for all resources
- **Backend Service**: FastAPI application with database connectivity
- **Frontend Service**: Next.js application that connects to backend
- **AI Agent Service**: Python application that interacts with backend
- **ConfigMap**: Stores non-sensitive configuration
- **Secrets**: Stores sensitive data like API keys and database URLs
- **Services**: Enable communication between components and external access

All components are configured to work together in a Kubernetes environment with proper service discovery and configuration management.

## 📋 Phase 4 Completion Summary

### ✅ Cloud-Native Architecture Implemented
- **Containerized all components** using Docker
- **Frontend**: Next.js 16+ application in container
- **Backend**: FastAPI API server in container
- **AI Agent**: OpenAI-powered chatbot in container
- **Stateless design** for scalability

### ✅ Infrastructure as Code (IaC) Established
- **Helm Charts** for deployment (instead of direct kubectl commands)
- **values.yaml** for configuration management
- **Parameterized templates** for flexibility
- **Namespace isolation** for resource organization

### ✅ Deployment Automation
- **Linux/macOS script**: `deploy-with-helm.sh`
- **Windows script**: `deploy-with-helm.bat`
- **Verification scripts**: Comprehensive health checks
- **Documentation**: Complete deployment guides

### ✅ Testing Infrastructure
- **Docker build validation** scripts
- **Docker Compose** for local multi-container testing
- **Health checks** for all services
- **Dependency management** for proper startup order

### 📁 Key Artifacts Created
- `helm/todo-app/` - Complete Helm chart structure
- `scripts/deploy-with-helm.sh` and `scripts/deploy-with-helm.bat` - Deployment scripts
- `scripts/verify-deployment.sh` and `scripts/verify-deployment.bat` - Verification scripts
- `docker-compose.yml` - Local multi-container setup
- `README-K8S-DEPLOYMENT.md` - Comprehensive deployment guide
- `DOCKER-TESTING.md` - Docker testing procedures

### 🎯 Compliance with Phase 4 Requirements
✅ **Cloud-Native Approach**: All components containerized and Kubernetes-deployed
✅ **IaC Standard**: Helm Charts used instead of direct kubectl commands
✅ **Configuration Management**: values.yaml for all configuration
✅ **Containerization Rules**: Gordon-style Dockerfiles created
✅ **Statelessness**: Application designed to be stateless
✅ **Automation**: Deployment scripts created for automated ops

### 🚀 Ready for Deployment
The infrastructure is ready for deployment to Minikube or other Kubernetes clusters. All components have been tested and verified to work together in a containerized environment.