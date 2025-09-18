#!/bin/bash
set -e

# Clean start
rm -rf output
mkdir -p output/python/lib/python3.13/site-packages

echo "MKDIR WORKED"

pwd   # debug check
ls -R output   # make sure directory exists

echo "output created"

docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

echo "docker buildx done"

docker run --rm -v "$PWD/output:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "mkdir -p /output/python/lib/python3.13/site-packages && cp -r /opt/python/. /output/python/lib/python3.13/site-packages/"


docker run --rm -it lambda-layer ls -lR /opt/python

echo "docker run done"
ls -R output   # <--- verify files are there

# Cleanup inside output/python
find output/python/ -type d -iname "tests" -exec rm -rf {} +
find output/python/ -type d -iname "test" -exec rm -rf {} +
find output/python/ -type d -name "__pycache__" -exec rm -rf {} +
find output/python/ -type f \( -name ".pyc" -o -name ".pyo" \) -delete
find output/python/ -type d -name "*.dist-info" -exec rm -rf {} +
find output/python/ -type d -name "*.egg-info" -exec rm -rf {} +

cd output/python
zip -r ../../lambda_layer.zip .
cd ../..
rm -rf output/python
echo "Test"
