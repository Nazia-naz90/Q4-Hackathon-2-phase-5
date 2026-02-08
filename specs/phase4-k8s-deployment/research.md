# Research for Phase 4: Local Kubernetes Deployment

## Technical Context Resolution

### Language/Versions
- **Backend**: Python 3.13.4 with FastAPI 0.128.0
- **Frontend**: TypeScript with Next.js 16.1.1, React 19.2.3
- **AI Agent**: Python 3.13.4 with OpenAI SDK and MCP framework

### Primary Dependencies
- **Backend**: FastAPI, SQLModel, SQLAlchemy, python-jose, passlib, python-dotenv, psycopg2-binary
- **Frontend**: React, Next.js, Tailwind CSS, shadcn/ui components
- **Deployment**: Docker, Kubernetes, Minikube, Helm

### Storage
- **Primary**: Neon PostgreSQL cloud database
- **Runtime**: Kubernetes persistent volumes (if needed)

### Testing
- **Backend**: pytest for API testing
- **Frontend**: Jest/React Testing Library (not currently implemented)
- **Integration**: Manual testing of deployment

### Target Platform
- **Development**: Local Minikube cluster on Windows
- **Runtime**: Kubernetes cluster with containerized components

### Performance Goals
- **API Response Time**: <200ms for typical requests
- **Container Startup Time**: <30 seconds for full deployment
- **Resource Usage**: Minimal resource consumption in local environment

### Constraints
- **Local Deployment**: Must run on developer machines with limited resources
- **Security**: Secrets must be managed securely via Kubernetes Secrets
- **Networking**: Internal service communication via Kubernetes DNS

### Scale/Scope
- **Users**: Single-user local development environment
- **Components**: 3 main services (backend, frontend, ai-agent)

## Research Findings

### Docker Best Practices for Multi-Component Applications

#### Backend (FastAPI) Dockerization
- Use multi-stage builds to reduce image size
- Copy dependencies first to leverage Docker layer caching
- Use non-root user for security
- Expose port 8000
- Set proper environment variables for database and API keys

#### Frontend (Next.js) Dockerization
- Use official Node.js Alpine base images
- Leverage Next.js production build and start commands
- Handle static asset serving properly
- Configure environment variables for API endpoints

#### AI Agent Dockerization
- Include necessary Python dependencies
- Configure proper entry point for agent service
- Set up environment for MCP communication
- Ensure connectivity to backend service

### Kubernetes Deployment Patterns

#### Namespace Strategy
- Create dedicated namespace for the application
- Use consistent naming conventions across all resources

#### Service Discovery
- Use Kubernetes internal DNS for service-to-service communication
- Backend service name: `todo-backend`
- Frontend service name: `todo-frontend`
- AI agent service name: `todo-ai-agent`

#### Secret Management
- Store sensitive data (database URL, API keys) in Kubernetes Secrets
- Mount secrets as environment variables or volumes
- Never commit secrets to version control

#### Deployment Strategies
- Use RollingUpdate strategy for zero-downtime deployments
- Configure resource limits and requests appropriately
- Set up health checks (liveness and readiness probes)

### Minikube Specific Considerations

#### Image Loading
- Use `minikube image load` to load local Docker images
- Alternatively, use `eval $(minikube docker-env)` to build directly in Minikube's Docker daemon

#### Port Forwarding
- Use `kubectl port-forward` to access services locally
- Configure LoadBalancer services to work with Minikube tunnel

#### Resource Allocation
- Configure Minikube with sufficient resources for all components
- Consider memory and CPU requirements for smooth operation

## Architecture Decisions

### 1. Container Registry Strategy
**Decision**: Use local image loading for development
**Rationale**: Simplifies local development workflow without requiring external registry
**Alternatives**:
- Docker Hub or other public registries (requires pushing images)
- Private registry (adds complexity for local development)

### 2. Service Communication Pattern
**Decision**: Use Kubernetes internal DNS for inter-service communication
**Rationale**: Standard Kubernetes pattern, enables service discovery without hardcoded IPs
**Alternatives**:
- Direct IP addresses (not recommended, breaks with pod recreation)
- External load balancers (unnecessary complexity for local development)

### 3. Configuration Management
**Decision**: Use combination of ConfigMaps for non-sensitive data and Secrets for sensitive data
**Rationale**: Follows Kubernetes best practices for configuration management
**Alternatives**:
- Environment variables only (doesn't scale well)
- External configuration stores (adds unnecessary complexity)

### 4. Persistent Storage
**Decision**: Use ephemeral storage for local development (can be changed to PVCs for production)
**Rationale**: Keeps local development simple, can be enhanced for production use
**Alternatives**:
- Kubernetes PersistentVolumeClaims (adds complexity for local development)
- External database (breaks self-contained deployment)

## Implementation Approach

### Phase 1: Containerization
1. Create Dockerfiles for each component
2. Build and test individual containers
3. Optimize images for size and security

### Phase 2: Kubernetes Manifests
1. Create Namespace manifest
2. Create Secret manifests for sensitive data
3. Create ConfigMap manifests for configuration
4. Create Deployment manifests for each service
5. Create Service manifests for networking

### Phase 3: Deployment and Testing
1. Start Minikube cluster
2. Apply Kubernetes manifests
3. Test service communication
4. Verify application functionality