#!/bin/bash

# Get the version from gitversion and remove quotes
VERSION=$(gitversion | jq -r .SemVer)
export VERSION

# Get the current date
BUILD_DATE=$(date '+%Y-%m-%d')
export BUILD_DATE

# Define the image name and version
IMAGE_NAME="docker.io/tmatwood/ubuntu-24.04"
IMAGE_NAME_AND_VERSION="$IMAGE_NAME:$VERSION"
IMAGE_NAME_LATEST="$IMAGE_NAME:latest"

echo "Image name: $IMAGE_NAME"
echo "Image name and version: $IMAGE_NAME_AND_VERSION"
echo "Image name latest: $IMAGE_NAME_LATEST"

podman build --platform linux/amd64 --build-arg BUILD_DATE="$BUILD_DATE" -t "${IMAGE_NAME_AND_VERSION}" .

podman tag "${IMAGE_NAME_AND_VERSION}" "${IMAGE_NAME_LATEST}"

podman push "${IMAGE_NAME_AND_VERSION}"
podman push "${IMAGE_NAME_LATEST}"
