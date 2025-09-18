#!/bin/bash
set -e

echo "Starting build_layer.sh"

# Clean previous build artifacts
rm -rf python lambda_layer.zip

# Create the directory structure on host machine before Docker volume mount
echo "Creating directory structure for Lambda layer on host"
mkdir -p /output/python/lib/python3.13/site-packages

# Build the Docker image with installed dependencies
echo "Building Docker image for Lambda layer"
docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

# Copy installed packages from Docker container to host directory via volume mount
echo "Copying installed packages from Docker container to host"
docker run --rm -v "$PWD:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "cp -r /opt/python/. /output/python/lib/python3.13/site-packages/"

# Remove unnecessary files to reduce layer size
echo "Cleaning unnecessary files"
find python/ -type d -iname "tests" -exec rm -rf {} +
find python/ -type d -iname "test" -exec rm -rf {} +
find python/ -type d -name "__pycache__" -exec rm -rf {} +
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete
find python/ -type d -name "*.dist-info" -exec rm -rf {} +
find python/ -type d -name "*.egg-info" -exec rm -rf {} +

# Ensure site-packages is non-empty before zipping
echo "Verifying Python packages before zipping"
if [ -z "$(ls -A python/lib/python3.13/site-packages)" ]; then
  echo "ERROR: site-packages directory is empty. Aborting layer creation."
  exit 1
fi

# Zip created packages as a Lambda layer package
echo "Creating lambda_layer.zip"
cd python
zip -r ../lambda_layer.zip .
cd ..

# Clean temporary python folder after zipping
rm -rf python

echo "Build complete. Lambda layer zip ready: lambda_layer.zip"
