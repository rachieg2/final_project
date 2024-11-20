#!/bin/bash

# Image name
IMAGE_NAME="project_env"

# Container name
CONTAINER_NAME="project_env"

# Check if the container is already running
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    if [ "$1" == "bash" ]; then
        echo "Container $CONTAINER_NAME is already running. Attaching to Bash..."
        docker exec -it $CONTAINER_NAME bash
    else
        echo "Container $CONTAINER_NAME is already running. Use './run_docker.sh bash' to enter Bash."
    fi
    exit 0
fi

# Check if the container exists but is not running
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Removing stopped container $CONTAINER_NAME..."
    docker rm $CONTAINER_NAME
fi

# Build the Docker image
docker build . -t $IMAGE_NAME

# Get the current directory
CURRENT_DIR=$(pwd)

# Run the Docker container
docker run -it -d --rm \
    --name $CONTAINER_NAME \
    -p 8787:8787 \
    -e PASSWORD=password \
    -e DISPLAY=$DISPLAY \
    -v "$CURRENT_DIR":/home/rstudio/work \
    --workdir /home/rstudio/work \
    $IMAGE_NAME

# Wait for the container to initialize
sleep 2

# Check if the user wants a Bash shell
if [ "$1" == "bash" ]; then
    docker exec -it $CONTAINER_NAME bash
else
    echo "Container $CONTAINER_NAME is running. Use './run_docker.sh bash' to enter Bash."
fi