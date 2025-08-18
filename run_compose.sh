#!/bin/bash

# Script to automate running Docker Compose

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Please install it following the instructions at https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose is not installed. Please install it following the instructions at https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null
then
    echo "Docker is not running. Please start Docker."
    exit 1
fi

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "docker-compose.yml not found in the current directory."
    exit 1
fi
# Run Docker Compose
echo "Starting Docker Compose..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo "Docker Compose started successfully."
else
    echo "Docker Compose failed to start."
    exit 1
fi