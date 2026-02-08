# Testing Deployment to OKE Cluster

## Overview

This document outlines the steps to test and validate your deployed application on Oracle Kubernetes Engine (OKE). Since actual deployment requires access to Oracle Cloud Infrastructure, this guide provides the procedures to verify your deployment once it's live.

## Pre-requisites

Before testing your deployment, ensure you have:

1. **OCI CLI installed** and configured with appropriate permissions
2. **kubectl** configured to connect to your OKE cluster
3. **Access to the GitHub repository** with the deployment files
4. **Valid OCI credentials** stored securely

## Step 1: Verify Cluster Connection

First, verify that you can connect to your OKE cluster:

```bash
# Check current kubectl context
kubectl config current-context

# List nodes in the cluster
kubectl get nodes

# Verify cluster info
kubectl cluster-info
```

## Step 2: Check Namespace and Resource Creation

Verify that all required namespaces and resources were created:

```bash
# Check all namespaces
kubectl get namespaces

# Verify the todo-app namespace exists
kubectl get ns todo-app

# Check the dapr-system namespace
kubectl get ns dapr-system

# Check the redpanda namespace
kubectl get ns redpanda
```

## Step 3: Verify Dapr Installation

Check that Dapr is properly installed and running:

```bash
# Check Dapr system pods
kubectl get pods -n dapr-system

# Verify Dapr operator is running
kubectl get deployments -n dapr-system

# Check Dapr components
kubectl get components.dapr.io -n todo-app
```

## Step 4: Check Application Pods

Verify that all application pods are running correctly:

```bash
# Check pods in todo-app namespace
kubectl get pods -n todo-app

# Check detailed status of each pod
kubectl describe pods -n todo-app

# Check logs for each application component
kubectl logs -l app=todo-backend -n todo-app
kubectl logs -l app=todo-frontend -n todo-app
kubectl logs -l app=todo-ai-agent -n todo-app
```

## Step 5: Verify Event Streaming (Redpanda)

Check that Redpanda is running and accessible:

```bash
# Check Redpanda pods
kubectl get pods -n redpanda

# Check Redpanda service
kubectl get svc -n redpanda

# Check Redpanda logs
kubectl logs -l app=redpanda -n redpanda
```

## Step 6: Verify State Store (Redis)

Check that Redis is running and accessible:

```bash
# Check Redis pods
kubectl get pods -n dapr-system

# Check Redis service
kubectl get svc redis-master -n dapr-system
```

## Step 7: Test Service Connectivity

Test connectivity between services:

```bash
# Check services in todo-app namespace
kubectl get svc -n todo-app

# Test internal connectivity using busybox pod
kubectl run test-pod -it --rm --image=busybox --restart=Never -- sh
# Inside the pod, test connectivity:
wget -O- http://todo-backend:8000/health
exit
```

## Step 8: Access the Application

Get the external IP for the frontend service:

```bash
# Get external IP for frontend
kubectl get svc todo-frontend -n todo-app

# Note: It may take a few minutes for the LoadBalancer to provision an external IP
# If using OCI LoadBalancer, it may take 5-10 minutes to become active
```

## Step 9: Functional Testing

Once the application is accessible, perform functional testing:

1. **Frontend Access**:
   - Navigate to the external IP/hostname of the frontend service
   - Verify the UI loads correctly
   - Test creating, updating, and deleting tasks

2. **Backend API**:
   - Access the backend API at `http://<external-ip>:8000/docs` for Swagger UI
   - Test API endpoints manually or with automated tests

3. **AI Agent Integration**:
   - Test the chatbot functionality
   - Verify AI commands are processed correctly
   - Check that AI operations affect the task list appropriately

4. **Dapr Integration**:
   - Verify service-to-service communication works through Dapr
   - Check that state is properly managed through Dapr state store
   - Verify event publishing/subscribing through Dapr pub/sub

## Step 10: Monitor Resource Usage

Check that resource usage is within expected bounds:

```bash
# Check resource usage for all pods
kubectl top pods -A

# Check resource limits and requests
kubectl describe pods -n todo-app
```

## Troubleshooting Common Issues

### Issue: Pods in CrashLoopBackOff
```bash
# Check pod logs
kubectl logs <pod-name> -n todo-app

# Check events for the pod
kubectl describe pod <pod-name> -n todo-app
```

### Issue: Services not getting external IP
```bash
# Check service status
kubectl describe svc todo-frontend -n todo-app

# Verify LoadBalancer is supported in your OCI region
```

### Issue: Dapr sidecar not injected
```bash
# Check if Dapr injector is running
kubectl get pods -n dapr-system

# Verify annotations in deployment
kubectl describe deployment todo-backend -n todo-app
```

### Issue: Application not connecting to database
```bash
# Check if secrets are properly mounted
kubectl describe pod <pod-name> -n todo-app

# Verify database connectivity from within the pod
kubectl exec -it <pod-name> -n todo-app -- sh
# Inside the pod, test database connection
```

## Performance Testing

Once the application is running, you can perform basic performance testing:

```bash
# Install hey for load testing (if available)
# Test frontend performance
hey -n 100 -c 10 http://<frontend-external-ip>

# Monitor during load testing
kubectl top pods -n todo-app
```

## Cleanup (Optional)

To clean up resources after testing:

```bash
# Delete the entire todo-app namespace and all resources
kubectl delete ns todo-app

# Or delete specific resources
kubectl delete -f k8s-manifests/oke/deployment-all.yaml
```

## Validation Checklist

- [ ] All pods running and ready in todo-app namespace
- [ ] Dapr sidecars injected and running for all services
- [ ] Redpanda (event streaming) operational
- [ ] Redis (state store) operational
- [ ] Services accessible internally
- [ ] Frontend service has external IP assigned
- [ ] Application responds to HTTP requests
- [ ] AI agent communicates with backend via Dapr
- [ ] Task operations work correctly
- [ ] Dapr components configured and operational
- [ ] Resource usage within Always Free tier limits
- [ ] No critical errors in application logs

## Expected Outcomes

Upon successful testing, you should observe:

1. All application components running stably in OKE
2. Dapr sidecars properly injected and communicating
3. Event-driven architecture functioning with Redpanda
4. State management working through Dapr and Redis
5. Application accessible via external load balancer
6. All functionality from previous phases preserved
7. Proper resource utilization within OCI Always Free tier limits