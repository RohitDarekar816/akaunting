#!/bin/bash

# Docker Test Script for Akaunting
echo "Testing Docker environment..."

# Check if docker compose is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Check if docker compose command works
if ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose is not available"
    exit 1
fi

echo "✓ Docker and Docker Compose are available"

# Check if required files exist
required_files=("Dockerfile" "docker-compose.yml" ".dockerignore")
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
    fi
done

# Check Docker configuration
echo ""
echo "=== Docker Configuration ==="
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"

echo ""
echo "=== Services in docker-compose.yml ==="
grep -A 1 "services:" docker-compose.yml

echo ""
echo "=== Port Mappings ==="
grep -E "ports:|-[0-9]+:" docker-compose.yml

echo ""
echo "=== Volume Mappings ==="
grep -A 10 "volumes:" docker-compose.yml

echo ""
echo "Docker environment test complete!"