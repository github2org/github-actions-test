#!/bin/bash
set -e

# Create the necessary host directory (not inside container)
mkdir -p python/python/lib/python3.13/site-packages

# Build Docker image
docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

# Run Docker container and copy layer files into host directory
docker run --rm -v "$PWD/python/python/lib/python3.13/site-packages:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "cp -r /opt/python/* /output/"

# Clean up unnecessary files
find python/ -type d -iname "tests" -exec rm -rf {} +
find python/ -type d -iname "test" -exec rm -rf {} +
find python/ -type d -name "__pycache__" -exec rm -rf {} +
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete
find python/ -type d -name "*.dist-info" -exec rm -rf {} +
find python/ -type d -name "*.egg-info" -exec rm -rf {} +

# Zip the layer
cd python
zip -r ../lambda_layer.zip .
cd ..

# Cleanup
rm -rf python
