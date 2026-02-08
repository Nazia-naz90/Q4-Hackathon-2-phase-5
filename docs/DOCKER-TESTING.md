# Docker Testing Guide

This document explains how to test the Docker containers for the Todo Application components.

## Overview

The Todo Application consists of three main components:
1. **Frontend**: Next.js 16+ application
2. **Backend**: FastAPI API server
3. **AI Agent**: OpenAI-powered chatbot component

Each component has its own Dockerfile optimized for production deployment.

## Individual Component Testing

### Build and Test Individual Images

You can build and test each component individually:

```bash
# Test backend build
docker build -t todo-backend:test -f ./backend/Dockerfile .

# Test frontend build
docker build -t todo-frontend:test -f ./frontend/Dockerfile .

# Test AI agent build
docker build -t todo-ai-agent:test -f ./ai-agent/Dockerfile .
```

### Quick Build Test

Use the provided test script to quickly verify all Dockerfiles build correctly:

```bash
./scripts/test-docker-builds.sh
```

## Complete Application Testing

### Using Docker Compose

For testing the complete application stack with all components connected:

```bash
# Build and start all services
docker-compose up --build

# Or using newer Docker Compose syntax
docker compose up --build
```

### Compose Services

The `docker-compose.yml` file defines:

- **db**: PostgreSQL database for persistence
- **backend**: FastAPI server connecting to the database
- **frontend**: Next.js application connecting to the backend
- **ai-agent**: AI component connecting to both backend and database

## Environment Variables

The following environment variables should be set for proper operation:

```bash
# In your .env file or environment
OPENAI_API_KEY=your-openai-api-key-here
```

## Health Checks

Each container includes health checks to ensure proper operation:
- Backend: `GET /health` endpoint
- Frontend: HTTP status check on main page
- AI Agent: `GET /health` endpoint
- Database: PostgreSQL readiness check

## Local Development

For local development with hot reloading, you may want to mount volumes:

```yaml
# Example for development in docker-compose.dev.yml
services:
  frontend:
    # ... other config
    volumes:
      - ./frontend/src:/app/src
    environment:
      - NODE_ENV=development
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Make sure ports 3000, 8000, 8080, and 5432 are available
2. **Insufficient memory**: Docker containers may need increased memory limits
3. **Dependency issues**: Ensure all required dependencies are included in Dockerfiles

### Useful Commands

```bash
# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f backend

# Check service status
docker-compose ps

# Clean up resources
docker-compose down -v
```

## Production Readiness

The Dockerfiles include several production-ready features:
- Multi-stage builds for smaller images
- Non-root users for security
- Proper health checks
- Optimized layer caching
- Minimal base images