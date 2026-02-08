# Phase 5 Quick Start Guide for Local Development

## Prerequisites
- Docker Desktop with Kubernetes enabled
- kubectl
- Dapr CLI
- Node.js and Python 3.13+

## Quick Setup Steps

### 1. Clone and Navigate to Project
```bash
cd D:\Q4-Hackathon\my-q4-hackathone-2\q4-hackathon-2-phase-05
```

### 2. Initialize Dapr
```bash
dapr init -k
```

### 3. Build Docker Images
```bash
# Backend
cd backend
docker build -t todo-backend:latest .
cd ..

# Frontend
cd frontend
docker build -t todo-frontend:latest .
cd ..

# AI Agent
cd ai-agent
docker build -t todo-ai-agent:latest .
cd ..
```

### 4. Update Secrets (Important!)
Edit `k8s-manifests/oke/namespaces-secrets-fixed.yaml` with your actual base64-encoded values:

```bash
# Example of generating base64 values
echo -n "your-neon-db-url" | base64
echo -n "your-secret-key" | base64
echo -n "your-openai-api-key" | base64
```

### 5. Deploy to Local Kubernetes
```bash
# Apply all components in order
kubectl apply -f k8s-manifests/oke/namespaces-secrets-fixed.yaml
kubectl apply -f k8s-manifests/oke/redis-statestore.yaml
kubectl apply -f k8s-manifests/oke/kafka-redpanda.yaml
kubectl apply -f k8s-manifests/oke/deployment-all-fixed.yaml

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod -l app=redis -n dapr-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=redpanda -n redpanda --timeout=180s
kubectl wait --for=condition=ready pod -l app=todo-backend -n todo-app --timeout=120s
kubectl wait --for=condition=ready pod -l app=todo-frontend -n todo-app --timeout=120s
kubectl wait --for=condition=ready pod -l app=todo-ai-agent -n todo-app --timeout=120s
```

### 6. Access the Application
```bash
# Check if services are running
kubectl get svc -n todo-app

# Use port forwarding to access the frontend
kubectl port-forward svc/todo-frontend -n todo-app 3000:3000

# In another terminal, access the backend
kubectl port-forward svc/todo-backend -n todo-app 8000:8000
```

## Verification Commands
```bash
# Check all pods
kubectl get pods -n todo-app
kubectl get pods -n dapr-system
kubectl get pods -n redpanda

# Check Dapr components
kubectl get components.dapr.io -n todo-app

# Check logs
kubectl logs -l app=todo-backend -n todo-app
kubectl logs -l app=todo-frontend -n todo-app
kubectl logs -l app=todo-ai-agent -n todo-app
```

## Clean Up
```bash
# Remove all deployed resources
kubectl delete -f k8s-manifests/oke/deployment-all-fixed.yaml
kubectl delete -f k8s-manifests/oke/kafka-redpanda.yaml
kubectl delete -f k8s-manifests/oke/redis-statestore.yaml
kubectl delete -f k8s-manifests/oke/namespaces-secrets-fixed.yaml
```

## Common Issues and Solutions

### Issue: Pods stuck in Init or Pending state
- Check if Dapr is properly initialized: `dapr status -k`
- Verify resource availability in Docker Desktop settings

### Issue: Cannot connect to database
- Ensure your Neon database URL is correctly base64 encoded in secrets
- Check that the database allows connections from your environment

### Issue: AI Agent not connecting to OpenAI
- Verify your OpenAI API key is correctly base64 encoded in secrets
- Check that your OpenAI account has proper permissions

### Issue: Frontend cannot reach backend
- Verify service names and namespaces in the configuration
- Check that Dapr sidecars are properly injected