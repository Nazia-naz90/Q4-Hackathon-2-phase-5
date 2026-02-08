# Phase 5: Cloud-Native Deployment on Oracle Cloud Infrastructure (OCI) OKE

## Overview

This phase transitions the AI-powered Todo application from local Minikube deployment to Oracle Cloud Infrastructure (OCI) with Oracle Kubernetes Engine (OKE). The architecture integrates Dapr for state management and Redpanda (Kafka-compatible) for event-driven messaging, creating a production-ready, cloud-native solution.

## Architecture Components

### 1. Oracle Kubernetes Engine (OKE)
- Deployed on Oracle Cloud Infrastructure using Always Free tier
- Utilizes A1.Flex ARM64 instances (up to 4 OCPUs, 24GB memory)
- Optimized for cost-effective cloud-native deployment

### 2. Dapr (Distributed Application Runtime)
- Sidecar injection for all microservices (frontend, backend, AI agent)
- Enables service invocation between components
- Provides state management through Redis
- Implements pub/sub messaging through Redpanda

### 3. Event-Driven Architecture
- **Redpanda**: Kafka-compatible streaming platform for event processing
- **Pub/Sub Pattern**: Asynchronous communication between services
- **Event Persistence**: Reliable message delivery and ordering

### 4. State Management
- **Redis**: Primary state store for caching and session management
- **Dapr State Store Component**: Abstracts state management complexity

## Deployment Structure

```
k8s-manifests/oke/
├── deployment-all.yaml         # Complete deployment manifest
├── dapr-components.yaml        # Dapr state store and pub/sub components
├── backend-deployment.yaml     # Backend service with Dapr sidecar
├── frontend-deployment.yaml    # Frontend service with Dapr sidecar
├── ai-agent-deployment.yaml    # AI agent with Dapr sidecar
├── kafka-redpanda.yaml         # Redpanda (Kafka-compatible) deployment
└── redis-statestore.yaml       # Redis state store deployment
```

## GitHub Actions CI/CD Pipeline

The `.github/workflows/deploy.yml` workflow automates the entire deployment process:

1. Builds Docker images for all services
2. Pushes images to Oracle Cloud Infrastructure Registry (OCIR)
3. Updates Kubernetes manifests with new image tags
4. Applies manifests to the OKE cluster
5. Verifies deployment status

## Required OCI Configuration

To deploy this solution, you'll need to configure the following GitHub Secrets:

- `ORACLE_REGION`: Your OCI region (e.g., us-ashburn-1)
- `COMPARTMENT_ID`: Your OCI compartment OCID
- `CLUSTER_NAME`: Your OKE cluster name
- `OCI_TENANCY`: Your OCI tenancy name
- `OCI_NAMESPACE`: Your object storage namespace
- `OCI_USERNAME`: Your OCI username (tenancy/username format)
- `OCI_AUTH_TOKEN`: Your OCI auth token
- `OCI_CONFIG`: Base64-encoded OCI config file content
- `OCI_PRIVATE_KEY`: Base64-encoded OCI private key content

## Dapr Integration Details

### Service Invocation
- AI Agent communicates with Backend using Dapr service invocation instead of direct API calls
- Frontend can leverage Dapr for state management and real-time updates

### State Management
- Tasks and user sessions stored in Redis via Dapr state store component
- Automatic serialization and deserialization of state

### Event-Driven Communication
- Task creation/update/deletion events published to Redpanda topics
- Asynchronous processing of AI requests and responses

## ARM64 Architecture Considerations

- All Docker images built with multi-architecture support (AMD64/ARM64)
- Optimized for Oracle's A1.Flex ARM64 instances
- Maintains performance while leveraging Always Free tier benefits

## Deployment Commands

### Manual Deployment (for testing)
```bash
# Apply all manifests to your OKE cluster
kubectl apply -f k8s-manifests/oke/deployment-all.yaml

# Verify all pods are running
kubectl get pods -n todo-app
kubectl get pods -n dapr-system
kubectl get pods -n redpanda

# Check services
kubectl get services -n todo-app
```

### Check Application Status
```bash
# View logs for any component
kubectl logs -l app=todo-backend -n todo-app
kubectl logs -l app=todo-frontend -n todo-app
kubectl logs -l app=todo-ai-agent -n todo-app

# Check Dapr sidecar status
kubectl get pods -n todo-app -o yaml | grep dapr
```

## Security Best Practices

- Secrets stored in Kubernetes Secrets and accessed via environment variables
- Dapr sidecars provide secure service-to-service communication
- Network policies can be added for additional security isolation
- TLS encryption enabled for all internal communications (configurable)

## Scaling Considerations

- Horizontal Pod Autoscaler (HPA) configurations can be added to deployments
- Dapr provides built-in service discovery and load balancing
- Redpanda can be scaled independently based on event throughput needs

## Monitoring and Observability

- Dapr provides built-in metrics and tracing capabilities
- Kubernetes native monitoring with Prometheus/Grafana
- OCI monitoring services for infrastructure metrics
- Application logging aggregated through Kubernetes logging solutions

## Troubleshooting

### Common Issues
1. **Image Pull Errors**: Verify OCIR credentials and image tags
2. **Dapr Sidecar Failures**: Check dapr-system namespace pods
3. **Service Connectivity**: Verify Dapr component configurations
4. **Resource Limits**: Adjust resource requests/limits based on Always Free tier constraints

### Debugging Commands
```bash
# Check Dapr placement service
kubectl get pods -n dapr-system

# Check Dapr component status
kubectl get components.dapr.io -n todo-app

# View Dapr logs
kubectl logs -l app=todo-backend -n todo-app -c daprd
```

## Next Steps

After successful deployment:
1. Monitor application performance and resource utilization
2. Set up proper monitoring and alerting
3. Implement backup and disaster recovery procedures
4. Consider implementing blue-green deployment strategies for production use