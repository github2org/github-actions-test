#!/bin/bash
set -e

# Create host-side folder for site-packages
mkdir -p python/python/lib/python3.13/site-packages

# Build Docker image with layer deps
docker buildx build --platform linux/amd64 \
  --no-cache \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .


# Copy the installed packages from Docker to host
docker run --rm -v "$PWD/python/python/lib/python3.13/site-packages:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "cp -r /opt/python/* /output/"

# Cleanup: remove test files, caches, etc.
find python/ -type d -iname "tests" -exec rm -rf {} +
find python/ -type d -iname "test" -exec rm -rf {} +
find python/ -type d -name "__pycache__" -exec rm -rf {} +
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete
find python/ -type d -name "*.dist-info" -exec rm -rf {} +
find python/ -type d -name "*.egg-info" -exec rm -rf {} +

# Create the final Lambda Layer zip
cd python
zip -r ../lambda_layer.zip .
cd ..

echo "build done"

# Clean up
rm -rf python
