# Todo Application Helm Chart

This Helm chart deploys the Todo Application which consists of:
- Frontend: Next.js 16+ application
- Backend: FastAPI API server with Neon PostgreSQL
- AI Agent: OpenAI-powered chatbot component

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Minikube (for local deployment)

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)    | `""`  |

### Frontend parameters

| Name                                    | Description                                                                 | Value       |
| --------------------------------------- | --------------------------------------------------------------------------- | ----------- |
| `frontend.replicaCount`                 | Number of frontend pods to run                                              | `1`         |
| `frontend.image.repository`             | Frontend image repository                                                   | `todo-frontend` |
| `frontend.image.tag`                    | Frontend image tag                                                          | `latest`    |
| `frontend.image.pullPolicy`             | Frontend image pull policy                                                  | `Never`     |
| `frontend.service.type`                 | Frontend service type                                                       | `LoadBalancer` |
| `frontend.service.port`                 | Frontend service port                                                       | `3000`      |

### Backend parameters

| Name                                  | Description                                                           | Value       |
| ------------------------------------- | --------------------------------------------------------------------- | ----------- |
| `backend.replicaCount`                | Number of backend pods to run                                         | `1`         |
| `backend.image.repository`            | Backend image repository                                              | `todo-backend` |
| `backend.image.tag`                   | Backend image tag                                                     | `latest`    |
| `backend.image.pullPolicy`            | Backend image pull policy                                             | `Never`     |
| `backend.service.type`                | Backend service type                                                  | `ClusterIP` |
| `backend.service.port`                | Backend service port                                                  | `8000`      |

### AI Agent parameters

| Name                                | Description                                                             | Value         |
| ----------------------------------- | ----------------------------------------------------------------------- | ------------- |
| `aiAgent.replicaCount`              | Number of AI agent pods to run                                          | `1`           |
| `aiAgent.image.repository`          | AI agent image repository                                               | `todo-ai-agent` |
| `aiAgent.image.tag`                 | AI agent image tag                                                      | `latest`      |
| `aiAgent.image.pullPolicy`          | AI agent image pull policy                                              | `Never`       |
| `aiAgent.service.port`              | AI agent service port                                                   | `8001`        |

### Database parameters

| Name                        | Description                               | Value       |
| --------------------------- | ----------------------------------------- | ----------- |
| `database.url`              | PostgreSQL database connection string     | `""`        |

### Secrets parameters

| Name                            | Description                           | Value                               |
| ------------------------------- | ------------------------------------- | ----------------------------------- |
| `secrets.openaiApiKey`          | OpenAI API key                        | `""`                                |
| `secrets.postgresUser`          | PostgreSQL username                   | `""`                                |
| `secrets.postgresPassword`      | PostgreSQL password                   | `""`                                |
| `secrets.postgresDb`            | PostgreSQL database name              | `""`                                |
| `secrets.secretKey`             | Application secret key                | `""`                                |

## Installing the Chart

To install the chart with the release name `my-todo-app`:

```console
# From the project root directory
# For local development with dummy values (not suitable for production)
helm install my-todo-app ./helm/todo-app \
  --set secrets.openaiApiKey="your-openai-key-here" \
  --set secrets.postgresUser="postgres" \
  --set secrets.postgresPassword="your-password" \
  --set secrets.postgresDb="todo_db" \
  --set secrets.secretKey="your-super-secret-key" \
  --set database.url="postgresql://postgres:your-password@your-db-host:5432/todo_db"
```

For production deployments, it's recommended to use a values file:

```console
# Create a secrets-values.yaml file with your sensitive data
helm install my-todo-app ./helm/todo-app -f secrets-values.yaml
```

## Security Best Practices

1. Never commit actual secrets to version control
2. Use Kubernetes secrets for sensitive data
3. For production, consider using external secret management solutions like HashiCorp Vault
4. Rotate your API keys and passwords regularly

## Upgrading the Chart

```console
helm upgrade my-todo-app ./helm/todo-app
```

## Uninstalling the Chart

```console
helm uninstall my-todo-app
```

## Local Development with Minikube

1. Start Minikube:
```console
minikube start
```

2. Build and load your Docker images into Minikube:
```console
# Set Docker environment to use Minikube's Docker daemon
eval $(minikube docker-env)

# Build your images
docker build -t todo-frontend:latest ./frontend
docker build -t todo-backend:latest ./backend
docker build -t todo-ai-agent:latest ./ai-agent
```

3. Install the chart:
```console
helm install my-todo-app ./helm/todo-app
```

4. Access the application:
```console
minikube service todo-frontend --url
```