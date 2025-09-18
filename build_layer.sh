#!/bin/bash
set -e

# Create the correct directory structure for Lambda layer (outside Docker, for output mount)
mkdir -p python/lib/python3.13/site-packages

# Build the Docker image
docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

# Run the Docker container, copy dependencies into output directory
docker run --rm -v "$PWD:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "mkdir -p /output/python/lib/python3.13/site-packages && cp -r /opt/python/* /output/python/lib/python3.13/site-packages/"

# Clean up unnecessary files to keep your layer small
find python/ -type d -iname "tests" -exec rm -rf {} +
find python/ -type d -iname "test" -exec rm -rf {} +
find python/ -type d -name "__pycache__" -exec rm -rf {} +
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete
find python/ -type d -name "*.dist-info" -exec rm -rf {} +
find python/ -type d -name "*.egg-info" -exec rm -rf {} +

echo "Packing layer as zip..."
cd python
zip -r ../lambda_layer.zip .
cd ..
rm -rf python
