# Quickstart Guide: Phase 4 - Local Kubernetes Deployment

## Overview
This guide provides step-by-step instructions to deploy the containerized Todo application to a local Minikube Kubernetes cluster.

## Prerequisites
- Docker Desktop (with Kubernetes disabled or using minikube)
- Minikube
- kubectl
- Helm (optional)
- Node.js (for local development)
- Python 3.13+ (for local development)

## Step 1: Install and Start Minikube

```bash
# Start Minikube with sufficient resources
minikube start --memory=4096 --cpus=2

# Enable ingress addon (optional)
minikube addons enable ingress
```

## Step 2: Build Container Images

### For Backend
```bash
# Navigate to backend directory
cd backend/

# Build the backend image
docker build -t todo-backend:latest .

# Go back to root
cd ..
```

### For Frontend
```bash
# Navigate to frontend directory
cd frontend/

# Build the frontend image
docker build -t todo-frontend:latest .

# Go back to root
cd ..
```

### For AI Agent
```bash
# Navigate to ai-agent directory
cd ai-agent/  # If this directory doesn't exist, create it

# Create Dockerfile and build the image
docker build -t todo-ai-agent:latest .

# Go back to root
cd ..
```

## Step 3: Load Images into Minikube

```bash
# Load all images into minikube's container runtime
minikube image load todo-backend:latest
minikube image load todo-frontend:latest
minikube image load todo-ai-agent:latest
```

Alternative approach:
```bash
# Set Docker environment to Minikube
eval $(minikube docker-env)

# Build images directly in minikube's environment
docker build -t todo-backend:latest ./backend
docker build -t todo-frontend:latest ./frontend
docker build -t todo-ai-agent:latest ./ai-agent

# Reset Docker environment back to normal
eval $(minikube docker-env -u)
```

## Step 4: Create Kubernetes Secrets

Create a file called `secrets.env` with your sensitive data:
```bash
DATABASE_URL=your_neon_database_url
OPENAI_API_KEY=your_openai_api_key
SECRET_KEY=your_jwt_secret_key
```

Then create the secret:
```bash
kubectl create namespace todo-app

kubectl create secret generic todo-secrets \
  --from-env-file=secrets.env \
  --namespace=todo-app
```

## Step 5: Deploy to Kubernetes

Apply all Kubernetes manifests:
```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Apply secrets (if not created via command line)
kubectl apply -f k8s/secrets.yaml

# Apply backend components
kubectl apply -f k8s/backend/

# Apply frontend components
kubectl apply -f k8s/frontend/

# Apply AI agent components
kubectl apply -f k8s/ai-agent/
```

## Step 6: Verify Deployment

Check if all resources are running:
```bash
# Check deployments
kubectl get deployments --namespace=todo-app

# Check services
kubectl get services --namespace=todo-app

# Check pods
kubectl get pods --namespace=todo-app

# Check logs for any issues
kubectl logs -l app=todo-backend --namespace=todo-app
kubectl logs -l app=todo-frontend --namespace=todo-app
kubectl logs -l app=todo-ai-agent --namespace=todo-app
```

## Step 7: Access the Application

### Using Port Forwarding
```bash
# Forward frontend port
kubectl port-forward svc/todo-frontend-service 3000:80 --namespace=todo-app

# Forward backend port (for API access)
kubectl port-forward svc/todo-backend-service 8000:8000 --namespace=todo-app
```

### Using Minikube Tunnel (for LoadBalancer services)
```bash
# In a separate terminal
minikube tunnel

# Then access the LoadBalancer IP shown in the services output
kubectl get services --namespace=todo-app
```

## Step 8: Troubleshooting

### Check Pod Status
```bash
kubectl describe pods --namespace=todo-app
```

### View Logs
```bash
# For a specific pod
kubectl logs <pod-name> --namespace=todo-app

# Follow logs in real-time
kubectl logs -f <pod-name> --namespace=todo-app
```

### Test Internal Service Communication
```bash
# Exec into a pod to test connectivity
kubectl exec -it <pod-name> --namespace=todo-app -- /bin/sh

# Inside the pod, test connectivity to other services
curl http://todo-backend-service:8000/
```

## Step 9: Clean Up

To remove the deployment:
```bash
# Delete all resources
kubectl delete namespace todo-app

# Or delete specific resources
kubectl delete -f k8s/ --namespace=todo-app
```

To stop Minikube:
```bash
minikube stop
```

## Common Issues and Solutions

### Issue: Images not found
**Solution**: Make sure to load images into Minikube using `minikube image load` or build them in the Minikube environment.

### Issue: Database connection errors
**Solution**: Verify that the DATABASE_URL in secrets is correct and that the database is accessible from within the cluster.

### Issue: Service-to-service communication fails
**Solution**: Check that services are named correctly and that internal DNS resolution works using service names like `http://service-name:port`.

### Issue: Resource limits exceeded
**Solution**: Adjust resource requests and limits in the deployment files based on your local machine's capabilities.