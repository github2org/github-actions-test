#!/bin/bash
set -e

# Clean previous build if exists
rm -rf python lambda_layer.zip

# Prepare output directory structure
mkdir -p python/lib/python3.13/site-packages

# Build Docker image
docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

# Run Docker container and copy installed dependencies
docker run --rm -v "$PWD:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "cp -r /opt/python/. /output/python/lib/python3.13/site-packages/"

# Clean unnecessary files
find python/ -type d -iname "tests" -exec rm -rf {} +
find python/ -type d -iname "test" -exec rm -rf {} +
find python/ -type d -name "__pycache__" -exec rm -rf {} +
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete
find python/ -type d -name "*.dist-info" -exec rm -rf {} +
find python/ -type d -name "*.egg-info" -exec rm -rf {} +

# Zip the content if non-empty
cd python
if [ "$(ls -A lib/python3.13/site-packages/)" ]; then
    zip -r ../lambda_layer.zip .
else
    echo "ERROR: site-packages is empty, aborting layer creation."
    exit 1
fi
cd ..
rm -rf python
