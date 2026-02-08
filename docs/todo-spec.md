# Todo Application Specification

## Phase 1: CLI Application
This phase established the foundational logic for managing todo items with basic CRUD operations using in-memory storage.

### Overview
- Basic todo item creation with title and description
- Display of todo items in a list format
- Marking todo items as completed/incomplete
- Updating todo items (title and description)
- Deleting todo items
- Persistence of todo items (in-memory storage using dictionary)
- CLI menu interface with options for all operations

## Phase 2: Full Stack Foundation
This phase introduced the web interface and backend API to create a full-stack application.

### Technologies
- **Frontend**: Next.js 16+ with App Router
- **Backend**: FastAPI with async patterns
- **Database**: SQLModel ORM with PostgreSQL
- **Authentication**: Better Auth for JWT-based authentication
- **Styling**: Tailwind CSS with responsive UI

### Features
- Complete web-based task management interface
- User authentication and session management
- Real-time task synchronization
- Responsive design for multiple device types

## Phase 3: AI Chatbot with MCP Integration
This phase integrated AI capabilities using OpenAI and Model Context Protocol (MCP).

### Technologies
- **AI Integration**: OpenAI GPT-4 Turbo
- **Protocol**: Model Context Protocol (MCP) for AI-agent communication
- **Processing**: Natural Language Processing for task management

### Features
- Conversational interface for task management
- Natural language processing for task creation and updates
- AI-powered suggestions and intelligent parsing
- MCP-enabled multi-agent coordination

## Phase 4: Cloud-Native Deployment with Kubernetes & Helm
This phase containerized the application and deployed it to a local Kubernetes cluster.

### Technologies
- **Orchestration**: Kubernetes with Minikube
- **Containerization**: Docker for all services
- **Deployment**: Helm Charts for deployment automation
- **Networking**: Service mesh with proper networking

### Features
- Containerized microservices architecture
- Helm-based deployment automation
- Service discovery and load balancing
- Auto-scaling and resilience patterns

## Phase 5: Cloud Native Deployment on Oracle Cloud Infrastructure

### Overview
This phase transitions the application from local Minikube deployment to Oracle Cloud Infrastructure (OCI) with Oracle Kubernetes Engine (OKE). The architecture integrates Dapr for state management and Kafka/Redpanda for event-driven messaging, creating a production-ready, cloud-native solution.

### Infrastructure Requirements
- **Oracle Kubernetes Engine (OKE)**: Deploy to OCI using Always Free tier with A1.Flex ARM64 shapes
- **Compute Resources**: Utilize up to 4 OCPUs and 24GB memory within Always Free limits
- **Architecture**: ARM64-compatible deployments to leverage A1.Flex instances
- **Storage**: 200GB block storage with appropriate persistence strategies

### Dapr Integration
- **Dapr Runtime**: Install Dapr on OKE cluster for distributed application runtime capabilities
- **Sidecar Configuration**: Configure Dapr sidecar injection for all microservices (frontend, backend, AI agent)
- **Service Invocation**: Enable inter-service communication through Dapr service invocation
- **State Management**: Implement state management using Dapr state store component
  - Primary: Redis for caching and session management
  - Fallback: OCI NoSQL for persistent state (custom component if needed)

### Event-Driven Architecture with Kafka/Redpanda
- **Streaming Platform**: Deploy Redpanda (Kafka-compatible) for event streaming
- **Pub/Sub Pattern**: Implement publish/subscribe messaging for asynchronous communication
- **Event Processing**: Enable real-time event processing between services
- **Message Persistence**: Ensure reliable message delivery and ordering

### Dapr Component Configuration

#### State Store Component (Redis)
```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
spec:
  type: state.redis
  version: v1
  metadata:
  - name: redisHost
    value: redis-master.dapr-system.svc.cluster.local:6379
  - name: redisPassword
    value: ""
  - name: actorStateStore
    value: "true"
  - name: concurrency
    value: "parallel"
```

#### Pub/Sub Component (Kafka/Redpanda)
```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub
spec:
  type: pubsub.kafka
  version: v1
  metadata:
  - name: brokers
    value: "redpanda-cluster-kafka-bootstrap.redpanda.svc.cluster.local:9092"
  - name: authType
    value: "none"
  - name: consumerGroup
    value: "my-dapr-consumer-group"
  - name: clientID
    value: "dapr-client"
  - name: disableTls
    value: "true"
```

### Service Modifications for Dapr Integration
- **Backend Service**: Register Dapr endpoints for task management operations
- **AI Agent**: Use Dapr service invocation to communicate with backend instead of direct API calls
- **Frontend**: Leverage Dapr for state management and real-time updates

### Deployment Architecture
- **Namespaces**: Separate namespaces for application (todo-app), Dapr (dapr-system), and Kafka/Redpanda (redpanda/kafka)
- **Resource Allocation**: Optimize resource requests/limits to fit within OKE Always Free constraints
- **Ingress**: Configure OCI Load Balancer for external access
- **Security**: Implement proper authentication and authorization with Dapr

### CI/CD Pipeline
- **GitHub Actions**: Automated build, test, and deployment pipeline
- **OCI Registry**: Push images to Oracle Cloud Infrastructure Registry (OCIR)
- **Helm Deployments**: Automated Helm chart deployments to OKE
- **Monitoring**: Integrated monitoring and logging solutions

### ARM64 Compatibility
- **Multi-arch Images**: Build container images supporting both AMD64 and ARM64 architectures
- **Base Images**: Use ARM64-compatible base images in Dockerfiles
- **Dependencies**: Ensure all application dependencies support ARM64 architecture

### Success Criteria
- Successful deployment to OKE cluster on OCI
- All services running with Dapr sidecars injected
- Event-driven communication working through Kafka/Redpanda
- Application accessible via OCI Load Balancer
- All functionality preserved from Phase 4
- Performance within acceptable parameters on ARM64 infrastructure
- Proper resource utilization within Always Free tier limits

### Constraints
- Must operate within OCI Always Free tier limits (4 OCPUs, 24GB RAM)
- All components must support ARM64 architecture
- Dapr integration should not significantly impact performance
- Event-driven patterns should enhance rather than complicate the architecture
- Security best practices must be maintained throughout the transition