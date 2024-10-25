#!/bin/bash

# Downloading nginx image from Docker Hub
docker pull reorks9/my-nginx-image

# Checking if the image was loaded successfully
if [ $? -eq 0 ]; then
    echo "The nginx image has been downloaded successfully."

    # Running the container in the background, mapping host port 80 to container port 80
    docker run -d -p 80:80 --name my-nginx-container-from-docker-hub reorks9/my-nginx-image

    # Checking if the container was successfully started
    if [ $? -eq 0 ]; then
        echo "The nginx container has successfully started on port 80."
    else
        echo "Error starting nginx container."
    fi
else
    echo "Error loading nginx image."
fi
