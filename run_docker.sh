#!/bin/bash

docker build . -t project_env

# Get the current directory
CURRENT_DIR=$(pwd)

# Run the Docker container
docker run -it --rm \
    --name project_env \
    -p 8787:8787 \
    -e PASSWORD=password \
    -e DISPLAY=$DISPLAY \
    -v "$CURRENT_DIR":/home/rstudio/work \
    --workdir /home/rstudio/work \
    project_env