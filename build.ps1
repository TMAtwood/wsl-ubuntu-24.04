# Get the version from gitversion and remove quotes
$VERSION = gitversion | ConvertFrom-Json | Select-Object -ExpandProperty SemVer
$env:VERSION = $VERSION

# Get the current date
$BUILD_DATE = Get-Date -Format "yyyy-MM-dd"
$env:BUILD_DATE = $BUILD_DATE

# Define the image name and version
$IMAGE_NAME = "localhost/tmatwood/ubuntu-24.04"
$IMAGE_NAME_AND_VERSION = "${IMAGE_NAME}:${VERSION}"
$IMAGE_NAME_LATEST = "${IMAGE_NAME}:latest"

Write-Host "Image name: ${IMAGE_NAME}"
Write-Host "Image name and version: ${IMAGE_NAME_AND_VERSION}"
Write-Host "Image name latest: ${IMAGE_NAME_LATEST}"

# Build the image
podman build --platform linux/amd64 --build-arg BUILD_DATE="${BUILD_DATE}" -t ${IMAGE_NAME_AND_VERSION} .

# Tag the built image as latest
podman tag ${IMAGE_NAME_AND_VERSION} ${IMAGE_NAME_LATEST}
