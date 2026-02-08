#!/bin/bash

# Docker Compose Test Script for Todo Application

set -e  # Exit on any error

echo "🐳 Testing Docker Compose setup for Todo Application..."

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed or not in PATH"
    echo "💡 Install Docker Compose or use 'docker compose' (Docker Desktop includes it)"
    exit 1
fi

echo "✅ Docker Compose is available"

# Test docker-compose configuration
echo "🧪 Testing Docker Compose configuration..."
if docker-compose config >/dev/null 2>&1 || docker compose config >/dev/null 2>&1; then
    echo "✅ Docker Compose configuration is valid"
else
    echo "❌ Docker Compose configuration is invalid"
    exit 1
fi

echo ""
echo "💡 To test the full setup, run:"
echo "   docker-compose up --build (or docker compose up --build)"
echo ""
echo "💡 To test in detached mode with health checks:"
echo "   docker-compose up --build -d && docker-compose ps"
echo ""
echo "💡 To stop and clean up:"
echo "   docker-compose down"