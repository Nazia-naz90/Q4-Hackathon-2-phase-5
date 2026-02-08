#!/bin/bash
# build-and-run.sh - Script to build and run the Next.js frontend container

set -e  # Exit on any error

echo "Building Next.js frontend container..."

# Build the Docker image
docker build -t nextjs-frontend:latest .

if [ $? -eq 0 ]; then
    echo "✅ Image built successfully!"

    echo "Starting container..."
    # Remove existing container if it exists
    if [ "$(docker ps -aq -f name=^nextjs-app$)" ]; then
        echo "Stopping existing container..."
        docker stop nextjs-app 2>/dev/null
        docker rm nextjs-app 2>/dev/null
    fi

    # Run the container
    docker run -d \
        --name nextjs-app \
        -p 3000:3000 \
        --restart unless-stopped \
        nextjs-frontend:latest

    if [ $? -eq 0 ]; then
        echo "✅ Container started successfully!"
        echo "Application is available at: http://localhost:3000"
        echo "Container name: nextjs-app"
        echo ""
        echo "To view logs: docker logs -f nextjs-app"
        echo "To stop container: docker stop nextjs-app"
    else
        echo "❌ Failed to start container"
        exit 1
    fi
else
    echo "❌ Failed to build image"
    exit 1
fi