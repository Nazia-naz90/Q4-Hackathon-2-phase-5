# Implementation Plan: Phase 4 - Local Kubernetes Deployment

**Branch**: `phase4-k8s-deployment` | **Date**: 2026-02-03 | **Spec**: [specs/phase4-k8s-deployment/spec.md]
**Input**: Feature specification from `/specs/phase4-k8s-deployment/spec.md`

## Summary

Implementation of a cloud-native, containerized deployment of the Todo Application featuring Next.js frontend, FastAPI backend, and AI Chatbot components orchestrated on a local Kubernetes cluster using Minikube and Helm for Infrastructure as Code. The architecture emphasizes stateless design, secure configuration management, and scalable microservices communication.

## Technical Context

**Language/Version**: Python 3.13.4, TypeScript/JavaScript, Next.js 16.1.1, React 19.2.3
**Primary Dependencies**: FastAPI, SQLModel, SQLAlchemy, Next.js, React, Docker, Kubernetes, Minikube, Helm
**Storage**: Neon PostgreSQL cloud database, ephemeral Kubernetes storage
**Testing**: pytest for backend, manual testing for deployment, Docker build validation
**Target Platform**: Local Minikube Kubernetes cluster on Windows/Linux/macOS
**Project Type**: web - multi-component web application with backend API, frontend UI, and AI agent
**Performance Goals**: <200ms API response time, <30s container startup, minimal local resource usage
**Constraints**: Local development environment, secure secret management, internal service communication
**Scale/Scope**: Single-user local development, 3 main services (backend, frontend, ai-agent)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Compliance with Phase 4 Constitution Requirements:**
✅ **Cloud-Native Architecture Priority**: All components containerized and Kubernetes-ready
✅ **IaC Standard**: Helm Charts used instead of direct kubectl commands
✅ **Automation & AI-Assisted Operations**: Deployment scripts created for automation
✅ **Containerization Rules**: Gordon-style Dockerfiles implemented
✅ **Statelessness & Resilience**: Stateless architecture designed for scalability

## Project Structure

### Documentation (this feature)

```text
specs/phase4-k8s-deployment/
├── plan.md                       # This file (/sp.plan command output)
├── research.md                   # Phase 0 output (/sp.plan command)
├── data-model.md                 # Phase 1 output (/sp.plan command)
├── quickstart.md                 # Phase 1 output (/sp.plan command)
├── contracts/                    # Phase 1 output (/sp.plan command)
└── tasks.md                      # Phase 2 output (/sp.tasks command - NOT created by /sp.plan)
```

### Source Code (repository root)

```text
helm/
└── todo-app/
    ├── Chart.yaml                # Chart metadata
    ├── values.yaml               # Configurable parameters
    ├── templates/                # Kubernetes resource templates
    │   ├── _helpers.tpl          # Template helper functions
    │   ├── backend-deployment.yaml
    │   ├── backend-service.yaml
    │   ├── frontend-deployment.yaml
    │   ├── frontend-service.yaml
    │   ├── ai-agent-deployment.yaml
    │   ├── ai-agent-service.yaml
    │   ├── secrets.yaml
    │   └── namespace.yaml
    └── README.md                 # Chart documentation

backend/
├── Dockerfile                    # Backend container definition (Gordon-style)
├── main.py                       # FastAPI application entry point
├── models.py                     # SQLModel database models
├── database.py                   # Database connection and setup
├── requirements.txt              # Python dependencies
└── ...

frontend/
├── Dockerfile                    # Frontend container definition (Gordon-style)
├── src/
│   ├── app/                      # Next.js app router pages
│   ├── components/               # React components
│   └── ...
├── package.json                  # Node.js dependencies
└── ...

ai-agent/
├── Dockerfile                    # AI agent container definition (Gordon-style)
├── main.py                       # Agent entry point
├── requirements.txt              # Python dependencies
└── ...

scripts/
├── deploy-with-helm.sh           # Linux/macOS deployment script
├── deploy-with-helm.bat          # Windows deployment script
├── verify-deployment.sh          # Linux/macOS verification script
├── verify-deployment.bat         # Windows verification script
└── test-docker-builds.sh         # Docker build validation script
```

**Structure Decision**: Cloud-native microservices architecture with containerized components orchestrated via Helm Charts for Infrastructure as Code. Each service maintains independence while enabling seamless communication through Kubernetes service discovery.

## Architecture Overview

### System Design: Stateless Microservices Architecture

The system follows a stateless, cloud-native architecture with three primary services:

1. **Frontend Service**: Next.js 16+ application serving the user interface
   - Stateless React application with server-side rendering capabilities
   - Communicates with Backend Service via HTTP/REST APIs
   - Exposed to external users via LoadBalancer service

2. **Backend Service**: FastAPI application providing API endpoints and business logic
   - Stateless API server with connection pooling to Neon PostgreSQL
   - Handles authentication, data validation, and business operations
   - Communicates with AI Agent for advanced operations

3. **AI Agent Service**: OpenAI-powered chatbot component
   - Stateless AI service for natural language processing
   - Integrates with Backend Service for data operations
   - Provides conversational interface for todo operations

### Containerization Strategy (Gordon-style)

Following Gordon (Docker AI) principles for lightweight, secure containers:

1. **Backend Container**:
   - Base: python:3.13.4-slim (minimal footprint)
   - Multi-stage build with dependency caching
   - Non-root user for security
   - Health checks and proper resource limits

2. **Frontend Container**:
   - Base: node:20-alpine with multi-stage build
   - Production build optimization
   - Standalone Next.js server
   - Health checks and security hardening

3. **AI Agent Container**:
   - Base: python:3.13.4-slim
   - Optimized for AI dependencies
   - Secure environment variable handling
   - Proper error handling and logging

## Kubernetes Orchestration Strategy

### Minikube Deployment Plan

The deployment utilizes a comprehensive Kubernetes orchestration strategy:

1. **Namespace Isolation**: Dedicated `todo-app` namespace for resource organization
2. **Service Discovery**: Internal DNS-based communication between services
3. **Configuration Management**: Kubernetes ConfigMaps and Secrets for environment variables
4. **Health Monitoring**: Liveness and readiness probes for all services
5. **Resource Management**: CPU and memory limits for stable performance

### Service Communication Architecture

- **Backend Service**: ClusterIP service at `todo-backend:8000`
- **Frontend Service**: LoadBalancer service exposing UI to external users
- **AI Agent Service**: ClusterIP service at `todo-ai-agent:8001`
- **Database Connectivity**: Neon PostgreSQL via environment variables in Secrets

### Environment Variable Management

Secure configuration through Kubernetes Secrets:
- `DATABASE_URL`: Neon PostgreSQL connection string
- `OPENAI_API_KEY`: OpenAI API authentication
- `NEXT_PUBLIC_API_URL`: Backend service URL for frontend
- `BACKEND_URL`: Backend service URL for AI agent

## Package Management with Helm

### Helm Chart Architecture

Deployment managed through comprehensive Helm chart:

1. **Chart Structure**:
   - `helm/todo-app/` - Main chart directory
   - Parameterized `values.yaml` for configuration
   - Template files for all Kubernetes resources
   - Helper functions for reusable logic

2. **Template Management**:
   - `backend-deployment.yaml`: Backend service deployment
   - `frontend-deployment.yaml`: Frontend service deployment
   - `ai-agent-deployment.yaml`: AI agent deployment
   - `*-service.yaml`: Service definitions for each component
   - `secrets.yaml`: Secure configuration storage
   - `namespace.yaml`: Namespace definition

3. **Configuration Parameters**:
   - Image repositories and tags
   - Resource limits and requests
   - Service types and ports
   - Replica counts for scaling

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Multi-component deployment | Required by Phase 4 objectives | Single service deployment insufficient for full application |
| Helm complexity | Infrastructure as Code requirement | Direct kubectl commands violate constitution |
| Multi-stage Docker builds | Security and optimization needs | Single-stage builds less secure and larger |
