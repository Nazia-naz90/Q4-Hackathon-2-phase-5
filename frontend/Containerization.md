# Containerizing the Next.js Frontend Application

This document provides a comprehensive guide for containerizing the Next.js frontend application using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose (optional, for orchestration with backend)
- Node.js and npm (for local development)

## Dockerfile Overview

The Dockerfile implements a multi-stage build process for optimized production images:

1. **Builder Stage**: Handles dependency installation and application build
2. **Production Stage**: Creates minimal production image with only necessary files

Key features:
- Uses Alpine Linux for smaller image size
- Implements non-root user for security
- Includes health check endpoint
- Optimized layer caching

## Step-by-Step Containerization Process

### 1. Build the Docker Image

```bash
# Navigate to the frontend directory
cd frontend

# Build the Docker image
docker build -t nextjs-frontend:latest .
```

### 2. Run the Container Locally

```bash
# Run the container on port 3000
docker run -p 3000:3000 nextjs-frontend:latest

# Or run in detached mode
docker run -d -p 3000:3000 --name nextjs-app nextjs-frontend:latest
```

### 3. Environment Variables Configuration

For production deployments, you may need to configure environment variables. Create a `.env.production` file or pass environment variables at runtime:

```bash
# Pass environment variables at runtime
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_API_URL=https://api.example.com \
  -e NEXT_PUBLIC_APP_NAME="My App" \
  nextjs-frontend:latest
```


### 4. Docker Compose Integration (Optional)

Create a `docker-compose.yml` file to orchestrate with backend services:

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=http://backend:8000
    depends_on:
      - backend
    restart: unless-stopped

  backend:
    # Your backend service configuration
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/myapp
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

### 5. Building and Running with Docker Compose

```bash
# Build and start all services
docker-compose up --build

# Run in detached mode
docker-compose up -d --build

# Stop services
docker-compose down
```

## Optimizations Implemented

### .dockerignore
- Excludes unnecessary files like `node_modules`, `.next`, logs, and development files
- Reduces build context size and improves build speed

### Multi-stage Build
- Separates build dependencies from production image
- Significantly reduces final image size
- Keeps production image minimal and secure

### Security Practices
- Runs container as non-root user
- Uses Alpine Linux base image for smaller attack surface
- Includes health check for container monitoring

### Health Check
- Monitors `/api/health` endpoint for application health
- Ensures container readiness for traffic
- Automatically handles health check failures

## Best Practices

1. **Image Tagging**: Use semantic versioning for image tags
   ```bash
   docker build -t nextjs-frontend:v1.0.0 .
   ```

2. **Build Arguments**: Use build arguments for customization
   ```bash
   docker build --build-arg NEXT_PUBLIC_API_URL=https://api.example.com -t nextjs-frontend .
   ```

3. **Resource Limits**: Set resource limits in production
   ```bash
   docker run -m 512m --memory-swap 1g nextjs-frontend
   ```

4. **Security Scanning**: Scan images for vulnerabilities
   ```bash
   docker scan nextjs-frontend:latest
   ```

## Troubleshooting

### Common Issues

1. **Build Failures**: Ensure all dependencies are properly declared in `package.json`
2. **Port Conflicts**: Check if port 3000 is already in use
3. **Environment Variables**: Verify all required environment variables are set

### Debugging

```bash
# Access container shell
docker exec -it nextjs-app sh

# Check container logs
docker logs nextjs-app

# Build with verbose output
docker build --progress=plain --no-cache .
```

## Production Deployment

For production deployments:

1. Push the image to a container registry
2. Configure a reverse proxy (nginx, traefik)
3. Set up SSL certificates
4. Implement monitoring and logging
5. Configure auto-scaling based on demand

## Additional Resources

- [Next.js Production Deployment](https://nextjs.org/docs/pages/building-your-application/deploying)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/security/)