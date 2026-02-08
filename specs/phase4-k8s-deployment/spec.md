# Phase 4: Local Kubernetes Deployment Specification

## Overview
This phase focuses on containerizing the existing full-stack Todo application and deploying it to a local Kubernetes cluster using Minikube. The application consists of:
- Frontend: Next.js 16+ application
- Backend: FastAPI API server with Neon PostgreSQL
- AI Agent: OpenAI-powered chatbot component

## Goals
1. Containerize all application components using Docker
2. Deploy the application to a local Kubernetes cluster using Minikube
3. Configure internal networking for inter-service communication
4. Securely manage sensitive configuration using Kubernetes Secrets
5. Enable local development and testing capabilities

## Architecture Requirements

### 1. Containerization Requirements
- Create optimized Dockerfiles for each component
- Backend Dockerfile must include Python dependencies and proper entry point
- Frontend Dockerfile must build and serve the Next.js application
- AI Agent Dockerfile must include necessary dependencies and configuration

### 2. Kubernetes Resources
- Create Deployments for each component (backend, frontend, ai-agent)
- Create Services to expose components internally and externally
- Create ConfigMaps for non-sensitive configuration
- Create Secrets for sensitive data (database URL, OpenAI API key, etc.)

### 3. Internal Networking
- Configure internal DNS resolution for inter-service communication
- AI Agent must communicate with Backend using internal service names
- Use standard service discovery mechanisms

### 4. Configuration Management
- Database connection details stored in Kubernetes Secrets
- Environment variables properly configured for each deployment
- Support for both development and production configurations

## Component Specifications

### Backend (FastAPI)
- **Image**: `todo-backend:latest`
- **Port**: 8000 (internally), exposed via Service
- **Environment Variables**:
  - `DATABASE_URL`: Neon PostgreSQL connection string
  - `SECRET_KEY`: JWT secret key
  - `OPENAI_API_KEY`: OpenAI API key (from Secret)
- **Health Checks**: Liveness and readiness probes
- **Storage**: Persistent volume for database (if needed)

### Frontend (Next.js)
- **Image**: `todo-frontend:latest`
- **Port**: 3000 (internally), exposed via Service
- **Environment Variables**:
  - `NEXT_PUBLIC_API_URL`: Backend service URL for API calls
- **Configuration**: Build-time environment variables

### AI Agent
- **Image**: `todo-ai-agent:latest`
- **Port**: 8080 (or appropriate port), exposed via Service
- **Environment Variables**:
  - `BACKEND_URL`: Internal URL to communicate with backend
  - `OPENAI_API_KEY`: OpenAI API key (from Secret)
- **Communication**: Must connect to backend using internal DNS

## Kubernetes Deployment Strategy

### Namespaces
- Deploy all resources in a dedicated namespace (e.g., `todo-app`)

### Services
- **Backend Service**: ClusterIP, internal communication
- **Frontend Service**: LoadBalancer or NodePort for external access
- **AI Agent Service**: ClusterIP, internal communication

### Ingress (Optional)
- Configure Ingress controller for unified access if needed

## Security Requirements
- Secrets must not be stored in plain text
- Use proper RBAC if required
- Image security scanning (optional but recommended)

## Local Development Considerations
- Minikube cluster configuration
- Image loading strategy (`minikube image load`)
- Port forwarding for local access
- Development vs production configurations

## Success Criteria
- All components successfully deployed to Minikube
- Inter-service communication working properly
- Application accessible via configured endpoints
- Health checks passing
- Proper error handling and logging

## Constraints
- Use imagePullPolicy: Never for local images
- Ensure proper PYTHONPATH and NODE_ENV settings
- Optimize Docker images for size and build time
- Follow security best practices for Kubernetes deployments