# Data Model for Phase 4: Local Kubernetes Deployment

## Overview
This document defines the data models for the containerized application components and Kubernetes resources required for the local deployment.

## Application Data Models

### 1. Task Model
Represents the core task entity managed by the application

**Fields**:
- `id` (string): Unique identifier for the task
- `title` (string): Title of the task
- `description` (string, optional): Detailed description of the task
- `status` (string): Current status ("pending", "completed")
- `priority` (string): Priority level ("low", "medium", "high")
- `due_date` (datetime, optional): Due date for the task
- `created_at` (datetime): Timestamp when task was created
- `updated_at` (datetime): Timestamp when task was last updated
- `completed_at` (datetime, optional): Timestamp when task was completed
- `user_id` (string): Reference to the user who owns the task

**Relationships**:
- Belongs to a User (many-to-one)

### 2. User Model
Represents application users

**Fields**:
- `id` (string): Unique identifier for the user
- `username` (string): Unique username
- `email` (string): User's email address
- `hashed_password` (string): BCrypt hashed password
- `created_at` (datetime): Account creation timestamp
- `updated_at` (datetime): Last update timestamp
- `is_active` (bool): Whether the account is active
- `is_admin` (bool): Whether the user has admin privileges
- `is_user` (bool): Whether the user has regular user privileges

**Relationships**:
- Has many Tasks (one-to-many)

## Kubernetes Resource Models

### 1. Namespace
Defines the isolation boundary for the application resources

**Fields**:
- `apiVersion` (string): "v1"
- `kind` (string): "Namespace"
- `metadata.name` (string): "todo-app" (or similar)

### 2. Secret
Stores sensitive configuration data

**Fields**:
- `apiVersion` (string): "v1"
- `kind` (string): "Secret"
- `metadata.name` (string): Name of the secret
- `metadata.namespace` (string): Target namespace
- `type` (string): "Opaque"
- `data` (map[string]string): Base64-encoded secret values

**Examples**:
- Database credentials
- API keys
- JWT secrets

### 3. ConfigMap
Stores non-sensitive configuration data

**Fields**:
- `apiVersion` (string): "v1"
- `kind` (string): "ConfigMap"
- `metadata.name` (string): Name of the config map
- `metadata.namespace` (string): Target namespace
- `data` (map[string]string): Configuration key-value pairs

**Examples**:
- API URLs
- Feature flags
- Environment-specific settings

### 4. Deployment
Defines how to run application containers

**Fields**:
- `apiVersion` (string): "apps/v1"
- `kind` (string): "Deployment"
- `metadata.name` (string): Name of the deployment
- `metadata.namespace` (string): Target namespace
- `spec.replicas` (int): Number of pod replicas
- `spec.selector.matchLabels` (map[string]string): Pod selector
- `spec.template.metadata.labels` (map[string]string): Pod labels
- `spec.template.spec.containers[]` (Container[]): Container definitions

**Container Definition**:
- `name` (string): Container name
- `image` (string): Container image reference
- `ports[]` (ContainerPort[]): Port mappings
- `env[]` (EnvVar[]): Environment variables
- `volumeMounts[]` (VolumeMount[]): Volume mounts
- `resources` (ResourceRequirements): Resource limits and requests

### 5. Service
Exposes pods to network traffic

**Fields**:
- `apiVersion` (string): "v1"
- `kind` (string): "Service"
- `metadata.name` (string): Name of the service
- `metadata.namespace` (string): Target namespace
- `spec.type` (string): Service type ("ClusterIP", "NodePort", "LoadBalancer")
- `spec.selector` (map[string]string): Selector for pods
- `spec.ports[]` (ServicePort[]): Port specifications

## Container Configuration Models

### 1. Backend Container
Configuration for the FastAPI backend service

**Environment Variables**:
- `DATABASE_URL`: Neon PostgreSQL connection string
- `SECRET_KEY`: JWT secret key
- `OPENAI_API_KEY`: OpenAI API key
- `ENVIRONMENT`: Runtime environment ("development", "production")

### 2. Frontend Container
Configuration for the Next.js frontend service

**Environment Variables**:
- `NEXT_PUBLIC_API_URL`: URL to backend API
- `NEXT_PUBLIC_APP_NAME`: Application name
- `NODE_ENV`: Node.js environment

### 3. AI Agent Container
Configuration for the AI agent service

**Environment Variables**:
- `BACKEND_URL`: Internal URL to backend service
- `OPENAI_API_KEY`: OpenAI API key
- `AGENT_NAME`: Name of the agent
- `MCP_SERVER_HOST`: MCP server host

## Internal Communication Models

### 1. API Request Model
Standard format for internal service communication

**Fields**:
- `method` (string): HTTP method
- `url` (string): Target URL
- `headers` (map[string]string): Request headers
- `body` (any, optional): Request body

### 2. API Response Model
Standard format for internal service responses

**Fields**:
- `status_code` (int): HTTP status code
- `headers` (map[string]string): Response headers
- `body` (any): Response body

## Validation Rules

### Task Model Validation
- Title must not be empty
- Status must be one of "pending", "completed"
- Priority must be one of "low", "medium", "high"
- Due date must be in the future (if provided)

### User Model Validation
- Username must be unique
- Email must be valid
- Password must meet complexity requirements
- Email must be unique

### Kubernetes Resource Validation
- All resource names must follow DNS-1123 naming conventions
- Container images must be accessible
- Resource limits must not exceed cluster capacity
- Service ports must not conflict with other services

## State Transitions

### Task State Transitions
- `pending` → `completed` (when task is marked as done)
- `completed` → `pending` (when task is unmarked as done)

### Deployment State Transitions
- `Active` → `Updating` (during rolling updates)
- `Updating` → `Active` (after successful update)
- `Active` → `Failed` (if deployment fails)
- `Failed` → `Active` (after fixing and redeploying)