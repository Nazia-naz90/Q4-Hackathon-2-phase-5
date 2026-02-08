# Todo Application Helm Chart - Deployment Guide

This guide provides instructions for deploying the Todo Application using Helm with proper security practices.

## Prerequisites

- Kubernetes cluster (Minikube, Kind, or cloud-based)
- Helm 3.0+
- kubectl

## Security Setup

This Helm chart follows security best practices by separating sensitive values from the main configuration:

1. **Main values** (non-sensitive) are stored in `values.yaml`
2. **Sensitive values** (API keys, passwords) are stored separately in `secrets-values.yaml`

## Deployment Steps

### 1. Prepare Your Sensitive Values

Create a `secrets-values.yaml` file with your actual credentials:

```yaml
# secrets-values.yaml
database:
  url: "postgresql://your_user:your_password@your_neon_db_url/todo_db"

secrets:
  openaiApiKey: "your_actual_openai_api_key"
  postgresUser: "your_postgres_user"
  postgresPassword: "your_secure_postgres_password"
  postgresDb: "todo_db"
  secretKey: "a_very_long_random_secret_key_for_production"
```

**Important**: Add this file to `.gitignore` and never commit it to version control.

### 2. Install the Chart

#### Option A: Using a secrets file
```bash
helm install my-todo-app ./todo-app -f secrets-values.yaml
```

#### Option B: Using --set flag
```bash
helm install my-todo-app ./todo-app \
  --set secrets.openaiApiKey="your_openai_key" \
  --set secrets.postgresUser="your_postgres_user" \
  --set secrets.postgresPassword="your_password" \
  --set secrets.postgresDb="todo_db" \
  --set secrets.secretKey="your_secret_key" \
  --set database.url="your_database_url"
```

### 3. Verify Installation

```bash
# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check secrets (to verify they were created properly)
kubectl get secrets
```

## Internal Service Communication

The application services communicate internally using Kubernetes DNS:

- Frontend connects to Backend at: `http://todo-backend:8000`
- AI Agent connects to Backend at: `http://todo-backend:8000`
- Both connect to database using the DATABASE_URL from secrets

## Production Considerations

1. **Secrets Management**: For production, consider using external secret management solutions like:
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - GCP Secret Manager

2. **Resource Limits**: The chart includes default resource requests and limits that should be adjusted based on your expected load.

3. **Health Checks**: Liveness and readiness probes are configured to ensure service stability.

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Services
```bash
kubectl get svc
kubectl describe svc <service-name>
```

### Debug Helm Release
```bash
helm status <release-name>
helm get manifest <release-name>
helm rollback <release-name> <revision>
```

## Uninstall

```bash
helm uninstall my-todo-app
```