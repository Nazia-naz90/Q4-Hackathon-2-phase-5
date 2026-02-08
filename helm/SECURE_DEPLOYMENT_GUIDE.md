# Secure Todo Application Deployment Guide

This guide explains how to deploy the Todo Application with zero sensitive data in your Helm chart files.

## Architecture Overview

- **No sensitive data** stored in Helm chart files
- **External Kubernetes secrets** for all sensitive information
- **Separation of concerns**: Configuration in Helm, secrets in Kubernetes

## Step 1: Create External Secrets

First, create the Kubernetes secret with your actual credentials:

```bash
kubectl create secret generic todo-app-secrets \
  --from-literal=DATABASE_URL="your_actual_database_url_here" \
  --from-literal=OPENAI_API_KEY="your_actual_openai_api_key_here" \
  --from-literal=SECRET_KEY="your_actual_secret_key_here" \
  --from-literal=POSTGRES_USER="your_actual_postgres_user_here" \
  --from-literal=POSTGRES_PASSWORD="your_actual_postgres_password_here" \
  --from-literal=POSTGRES_DB="your_actual_postgres_db_here"
```

## Step 2: Deploy the Helm Chart

Deploy the chart without any sensitive data:

```bash
# Using the safe template values
helm install my-todo-app ./todo-app -f values-safe-template.yaml

# Or with custom values (still no secrets)
helm install my-todo-app ./todo-app --set global.imageRegistry="your-registry"
```

## Step 3: Verify Deployment

```bash
# Check pods
kubectl get pods

# Check services
kubectl get svc

# Verify secrets are referenced properly
kubectl describe deployment todo-backend
kubectl describe deployment todo-ai-agent
```

## Optional: Enable Default Secret Creation (Not Recommended)

If you need to create default secrets through Helm (for development only), you can override the default:

```bash
helm install my-todo-app ./todo-app --set createDefaultSecret=true --set secrets.openaiApiKey="key" ...
```

But this is NOT recommended for production environments.

## Security Benefits

✅ No sensitive data in version control
✅ Secrets managed by Kubernetes
✅ Clear separation of configuration and secrets
✅ Follows security best practices
✅ Compliant with enterprise security policies

## Cleanup

To remove the application:

```bash
helm uninstall my-todo-app
kubectl delete secret todo-app-secrets  # If no longer needed
```