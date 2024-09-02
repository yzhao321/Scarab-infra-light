#!/bin/bash

# Extract values from config.json using jq
CONFIG_FILE="config.json"
USER_NAME=$(jq -r '.USER_NAME' $CONFIG_FILE)
MOUNT_DIR=$(jq -r '.MOUNT_DIR' $CONFIG_FILE)
APPLICATION_NAME=$(jq -r '.APPLICATION_NAME' $CONFIG_FILE)

# Concatenate strings
APPLICATION_NAME="${APPLICATION_NAME}_${USER_NAME}"
APPLICATION_TAG="${APPLICATION_NAME}:v1.0"

# Function to build the Docker image
build_image() {
    echo "Building Docker image..."
    docker build -t $APPLICATION_TAG .
}

# Function to run the Docker container
run_container() {
    echo "Running Docker container..."
    docker run -e username=$USER_NAME -e HOME=/home/$USER_NAME \
    -dit --privileged --name $APPLICATION_NAME \
    --mount type=bind,source=$MOUNT_DIR,target=/home/$USER_NAME \
    $APPLICATION_TAG
}

# Function to exec into the Docker container
exec_container() {
    echo "Executing into Docker container..."
    docker exec -it -u $USER_NAME -w /home/$USER_NAME --privileged $APPLICATION_NAME bash
}

# Check for the correct number of arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 {build|run|exec}"
    exit 1
fi

# Select the operation based on the argument
case "$1" in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    exec)
        exec_container
        ;;
    *)
        echo "Invalid option: $1"
        echo "Usage: $0 {build|run|exec}"
        exit 1
        ;;
esac
