#!/bin/bash
# Deployment script for Todo Application on Kubernetes

set -e  # Exit on any error

echo "Starting deployment of Todo Application to Kubernetes..."

# Create secrets (you'll need to populate these with actual values)
echo "Creating secrets..."
kubectl apply -f k8s/secrets.yaml

# Deploy backend
echo "Deploying backend..."
kubectl apply -f k8s/backend/deployment.yaml
kubectl apply -f k8s/backend/service.yaml

# Deploy frontend
echo "Deploying frontend..."
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml

# Deploy AI agent
echo "Deploying AI agent..."
kubectl apply -f k8s/ai-agent/deployment.yaml
kubectl apply -f k8s/ai-agent/service.yaml

echo "Deployment completed!"
echo ""
echo "To check the status of your deployments:"
echo "kubectl get pods"
echo "kubectl get services"
echo ""
echo "To access the frontend service:"
echo "minikube service todo-frontend --url"