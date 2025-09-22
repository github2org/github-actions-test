#!/bin/bash
set -e

mkdir -p python/python/lib/python3.13/site-packages

docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

docker run --rm -v "$PWD:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "cp -r /opt/python/* /output/python/python/lib/python3.13/site-packages/"

# Remove test folders
find python/ -type d -iname "tests" -exec rm -rf {} +
find python/ -type d -iname "test" -exec rm -rf {} +

# Remove __pycache__ folders
find python/ -type d -name "__pycache__" -exec rm -rf {} +

# Remove *.pyc and *.pyo files
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete

# Remove dist-info metadata if you don’t need it at runtime
# (optional: can save 10-20 MB)
find python/ -type d -name "*.dist-info" -exec rm -rf {} +

# Remove *.egg-info if present
find python/ -type d -name "*.egg-info" -exec rm -rf {} +

echo NOONOANONAOANO
cd python
zip -r ../lambda_layer.zip .
cd ..
sudo rm -rf python
