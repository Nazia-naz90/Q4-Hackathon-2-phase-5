# Phase 4: Local Kubernetes Deployment Guide

This document describes the process of containerizing the Todo Application and deploying it to a local Kubernetes cluster using Minikube and Helm.

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Deployment Process](#deployment-process)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Cleanup](#cleanup)

## Overview

Phase 4 focuses on deploying the Todo Application to a local Kubernetes cluster using industry-standard tools:
- **Docker** for containerization
- **Minikube** for local Kubernetes cluster
- **Helm** for Infrastructure as Code (IaC)

The application consists of three main components:
1. **Frontend**: Next.js 16+ application (port 3000)
2. **Backend**: FastAPI API server (port 8000)
3. **AI Agent**: OpenAI-powered chatbot component (port 8001)

## Architecture

The deployment follows cloud-native principles:
- Each component is containerized separately
- Components communicate via internal Kubernetes services
- Configuration is managed through Helm values
- Sensitive data is stored in Kubernetes Secrets
- The application is designed to be stateless for scalability

### Service Communication
- Frontend connects to Backend using: `http://todo-backend:8000`
- AI Agent connects to Backend using: `http://todo-backend:8000`
- All components connect to the Neon PostgreSQL database

## Prerequisites

Before deploying, ensure you have:

1. **Docker** installed and running
2. **kubectl** installed
3. **Helm** installed (version 3.x)
4. **Minikube** installed (for local deployment)

### Installation Commands

On Windows with Chocolatey:
```powershell
choco install docker-desktop kubernetes-cli helm minikube
```

On macOS with Homebrew:
```bash
brew install docker kubernetes-cli helm minikube
```

On Linux:
```bash
# Docker (Ubuntu/Debian)
sudo apt-get update && sudo apt-get install docker.io

# Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

## Deployment Process

### Step 1: Start Minikube

```bash
minikube start
```

### Step 2: Set Docker Environment (Optional)

If you want to build images directly in Minikube's Docker environment:

```bash
# On Linux/macOS
eval $(minikube docker-env)

# On Windows PowerShell
& minikube docker-env | Invoke-Expression
```

### Step 3: Build Docker Images

Build the container images for each component:

```bash
# Backend
docker build -t todo-backend:latest ./backend

# Frontend
docker build -t todo-frontend:latest ./frontend

# AI Agent
docker build -t todo-ai-agent:latest ./ai-agent
```

### Step 4: Customize Configuration (Optional)

Edit the `helm/todo-app/values.yaml` file to customize:
- Database connection string
- API keys
- Resource limits
- Replica counts

### Step 5: Deploy with Helm

Using the provided deployment script:

```bash
# On Linux/macOS
./scripts/deploy-with-helm.sh

# On Windows
.\scripts\deploy-with-helm.bat
```

Or deploy manually:

```bash
helm upgrade --install todo-app ./helm/todo-app --namespace todo-app --create-namespace --timeout=10m
```

## Verification

### Check Pod Status
```bash
kubectl get pods -n todo-app
```

### Check Services
```bash
kubectl get svc -n todo-app
```

### Check Deployments
```bash
kubectl get deployments -n todo-app
```

### Access the Application

If using Minikube:
```bash
minikube service todo-frontend -n todo-app --url
```

### View Logs
```bash
# Backend logs
kubectl logs -l app=todo-backend -n todo-app

# Frontend logs
kubectl logs -l app=todo-frontend -n todo-app

# AI Agent logs
kubectl logs -l app=todo-ai-agent -n todo-app
```

## Troubleshooting

### Common Issues

#### 1. Images not found
If using Minikube, ensure you've set the Docker environment:
```bash
eval $(minikube docker-env)  # Linux/macOS
```

#### 2. Insufficient resources
Increase Minikube resources:
```bash
minikube start --memory=4096 --cpus=4
```

#### 3. Pod stuck in Pending state
Check resource limits in values.yaml and ensure Minikube has sufficient resources.

#### 4. Connection timeouts
Verify that services can communicate with each other using internal DNS names.

### Debug Commands

```bash
# Describe a specific pod for detailed information
kubectl describe pod <pod-name> -n todo-app

# Get detailed service information
kubectl describe svc todo-backend -n todo-app

# Execute commands inside a pod
kubectl exec -it <pod-name> -n todo-app -- /bin/sh
```

## Cleanup

To remove the entire deployment:

```bash
helm uninstall todo-app -n todo-app
kubectl delete namespace todo-app
```

To stop Minikube:
```bash
minikube stop
```

## Best Practices

1. **Security**: Never commit actual API keys to version control
2. **Configuration**: Use Helm values for environment-specific configuration
3. **Monitoring**: Implement proper logging and health checks
4. **Resource Management**: Set appropriate resource limits and requests
5. **Rollbacks**: Helm supports easy rollbacks with `helm rollback`

## Next Steps

After successful deployment, consider:
- Setting up Ingress for unified access
- Implementing monitoring with Prometheus/Grafana
- Adding persistent volumes for data storage
- Setting up CI/CD pipelines
- Implementing advanced networking policies