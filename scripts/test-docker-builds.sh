#!/bin/bash

# Docker Build Test Script for Todo Application Components

set -e  # Exit on any error

echo "🐳 Testing Docker builds for Todo Application components..."

# Test Backend Docker build
echo "🧪 Testing Backend Docker build..."
if docker build -t todo-backend:test -f ./backend/Dockerfile . 2>/dev/null; then
    echo "✅ Backend Docker build successful"
    docker rmi todo-backend:test > /dev/null 2>&1 || true
else
    echo "❌ Backend Docker build failed"
    exit 1
fi

# Test Frontend Docker build
echo "🧪 Testing Frontend Docker build..."
if docker build -t todo-frontend:test -f ./frontend/Dockerfile . 2>/dev/null; then
    echo "✅ Frontend Docker build successful"
    docker rmi todo-frontend:test > /dev/null 2>&1 || true
else
    echo "❌ Frontend Docker build failed"
    exit 1
fi

# Test AI Agent Docker build
echo "🧪 Testing AI Agent Docker build..."
if docker build -t todo-ai-agent:test -f ./ai-agent/Dockerfile . 2>/dev/null; then
    echo "✅ AI Agent Docker build successful"
    docker rmi todo-ai-agent:test > /dev/null 2>&1 || true
else
    echo "❌ AI Agent Docker build failed"
    exit 1
fi

echo "🎉 All Docker builds successful!"
echo ""
echo "To build images for deployment, run:"
echo "  docker build -t todo-backend:latest -f ./backend/Dockerfile ."
echo "  docker build -t todo-frontend:latest -f ./frontend/Dockerfile ."
echo "  docker build -t todo-ai-agent:latest -f ./ai-agent/Dockerfile ."