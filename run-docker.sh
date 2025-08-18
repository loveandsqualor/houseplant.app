#!/bin/bash

# Run with Docker Compose (preferred)
if command -v docker-compose &> /dev/null; then
    echo "Starting application with Docker Compose..."
    docker-compose down
    docker-compose up --build -d
    echo "Application is running at http://localhost:8084"
    echo "Admin login: admin@houseplant.app / admin123"
else
    # Fallback to direct Docker commands
    echo "Docker Compose not found, using Docker directly..."
    
    # Stop and remove existing container if it exists
    if [ "$(docker ps -q -f name=botanical-bliss)" ]; then
        docker stop botanical-bliss
        docker rm botanical-bliss
    fi
    
    # Build image
    docker build -t botanical-bliss .
    
    # Run container
    docker run -d \
        --name botanical-bliss \
        -p 8084:8080 \
        -v $(pwd)/houseplants.db:/app/houseplants.db \
        -v $(pwd)/uploads:/app/uploads \
        -v $(pwd)/logs:/app/logs \
        --env-file .env \
        botanical-bliss
    
    echo "Application is running at http://localhost:8084"
    echo "Admin login: admin@houseplant.app / admin123"
fi
