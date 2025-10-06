#!/bin/bash

# Deployment Script for Online Book Bazaar Application
# This script deploys the application using Docker

echo "🚀 Starting deployment of Online Book Bazaar application..."

# Configuration
APP_NAME="book-bazaar-app"
APP_PORT="8000"
CONTAINER_PORT="3000"
HEALTH_ENDPOINT="/health"

# Check if Docker is running
if ! docker --version > /dev/null 2>&1; then
    echo "❌ Docker is not installed or not running"
    exit 1
fi

# Stop existing container
echo "🛑 Stopping existing application container..."
docker stop $APP_NAME 2>/dev/null || echo "No existing container to stop"
docker rm $APP_NAME 2>/dev/null || echo "No existing container to remove"

# Load Docker image if tar file exists
if [ -f "book-bazaar-app-*.tar" ]; then
    echo "📦 Loading Docker image from tar file..."
    docker load < book-bazaar-app-*.tar
else
    echo "📦 Using existing Docker image..."
fi

# Start new container
echo "🚀 Starting new application container..."
docker run -d \
    --name $APP_NAME \
    -p $APP_PORT:$CONTAINER_PORT \
    --restart unless-stopped \
    book-bazaar-app:latest

# Wait for application to start
echo "⏳ Waiting for application to start..."
sleep 15

# Health check
echo "🔍 Performing health check..."
if curl -f http://localhost:$APP_PORT$HEALTH_ENDPOINT > /dev/null 2>&1; then
    echo "✅ Application is healthy and running!"
    echo "🌐 Application URL: http://$(curl -s ifconfig.me):$APP_PORT"
    echo "💚 Health check: http://$(curl -s ifconfig.me):$APP_PORT$HEALTH_ENDPOINT"
else
    echo "❌ Health check failed"
    echo "📋 Container logs:"
    docker logs $APP_NAME --tail 20
    exit 1
fi

# Show container status
echo ""
echo "📊 Container Status:"
docker ps --filter name=$APP_NAME --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Cleanup
echo "🧹 Cleaning up..."
rm -f book-bazaar-app-*.tar

echo ""
echo "✅ Deployment completed successfully!"
