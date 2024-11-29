#!/bin/bash

# Get the version from gitversion and remove quotes
VERSION=$(gitversion | jq .SemVer | tr -d '"')
export VERSION

# Get the current date
BUILD_DATE=$(date '+%Y%m%d')
export BUILD_DATE

# Define image name and version
IMAGE_NAME="docker.io/tmatwood/ubuntu-24.04"
IMAGE_AND_VERSION="$IMAGE_NAME:$VERSION"

# Use docker buildx to create a builder instance if it doesn't exist
docker buildx create --use || docker buildx use default

# Build the image for multiple platforms and push it to the registry
docker buildx build --platform linux/amd64,linux/arm64 --build-arg VERSION="$VERSION" --build-arg BUILD_DATE="$BUILD_DATE" -t "$IMAGE_AND_VERSION" -t "$IMAGE_NAME:latest" -f Dockerfile .

# The --push flag pushes the built images to the registry specified in the image name

docker push "$IMAGE_AND_VERSION"
docker push "$IMAGE_NAME:latest"
