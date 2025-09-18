#!/bin/bash
set -e

# Clean previous outputs
rm -rf python lambda_layer.zip

# Ensure host directory for Docker mounted copy target exists before Docker run
mkdir -p python/lib/python3.13/site-packages

# Build Docker image with dependencies installed for correct platform
docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

# Run Docker container and copy installed packages into host directory
docker run --rm -v "$PWD:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "cp -r /opt/python/. /output/python/lib/python3.13/site-packages/"

# Remove unwanted files to reduce layer size
find python/ -type d -iname "tests" -exec rm -rf {} +
find python/ -type d -iname "test" -exec rm -rf {} +
find python/ -type d -name "__pycache__" -exec rm -rf {} +
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete
find python/ -type d -name "*.dist-info" -exec rm -rf {} +
find python/ -type d -name "*.egg-info" -exec rm -rf {} +

# Zip only if site-packages contains files, else abort with error
cd python
if [ "$(ls -A lib/python3.13/site-packages/)" ]; then
    zip -r ../lambda_layer.zip .
else
    echo "ERROR: site-packages is empty. Aborting layer creation."
    exit 1
fi
cd ..

# Clean temporary build directory
rm -rf python

echo "Lambda layer zip created: lambda_layer.zip"
