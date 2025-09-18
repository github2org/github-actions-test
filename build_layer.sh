#!/bin/bash
set -e

echo "Starting build_layer.sh"

# Clean previous artifacts
rm -rf python lambda_layer.zip

# Create directory structure on host for the Docker volume mount target
echo "Creating directory structure for Lambda layer on host"
mkdir -p python/lib/python3.13/site-packages

# Build the Docker image with dependencies
echo "Building Docker image for Lambda layer"
docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

# Run the container copying the installed packages into the mounted host dir
echo "Copying installed packages from Docker container to host"
docker run --rm -v "$PWD:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "cp -r /opt/python/. /output/python/lib/python3.13/site-packages/"

# Clean unnecessary files to reduce package size
echo "Removing unnecessary files"
find python/ -type d -name "tests" -exec rm -rf {} +
find python/ -type d -name "test" -exec rm -rf {} +
find python/ -type d -name "__pycache__" -exec rm -rf {} +
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete
find python/ -type d -name "*.dist-info" -exec rm -rf {} +
find python/ -type d -name "*.egg-info" -exec rm -rf {} +

# Verify site-packages is not empty before zipping
echo "Verifying Python packages prior to zipping"
if [ -z "$(ls -A python/lib/python3.13/site-packages)" ]; then
  echo "ERROR: site-packages directory is empty. Aborting layer creation."
  exit 1
fi

# Zip the layer content
echo "Creating lambda_layer.zip"
cd python
zip -r ../lambda_layer.zip .
cd ..

# Cleanup
rm -rf python

echo "Build complete. Lambda layer zip ready: lambda_layer.zip"
