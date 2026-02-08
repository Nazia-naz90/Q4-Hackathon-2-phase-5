#!/bin/bash

# Deployment script for Todo Application using Helm

set -e  # Exit on any error

echo "🚀 Starting deployment of Todo Application..."

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if we're connected to a Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Not connected to a Kubernetes cluster. Please start Minikube or connect to a cluster."
    exit 1
fi

# Optional: Set Docker environment to use Minikube's Docker daemon (uncomment if using Minikube)
# eval $(minikube docker-env)

echo "✅ Prerequisites check passed"

# Build Docker images (optional, uncomment if you want to rebuild)
# echo "🐳 Building Docker images..."
# docker build -t todo-frontend:latest ./frontend
# docker build -t todo-backend:latest ./backend
# docker build -t todo-ai-agent:latest ./ai-agent

echo "📊 Installing/upgrading Helm release..."

# Install or upgrade the Helm release
helm upgrade --install todo-app ./helm/todo-app --namespace todo-app --create-namespace --timeout=10m

echo "✅ Helm release installed/updated successfully!"

# Wait for all deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=todo-app --timeout=300s -n todo-app

echo "✅ All pods are ready!"

# Show the services
echo "🌐 Services:"
kubectl get svc -n todo-app

# Show the deployments
echo "📦 Deployments:"
kubectl get deployments -n todo-app

# If using Minikube, provide the URL to access the frontend
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo "💡 To access the frontend in Minikube:"
    echo "   minikube service todo-frontend -n todo-app --url"
fi

echo "🎉 Deployment completed successfully!"