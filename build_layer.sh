#!/bin/bash
set -e

rm -rf output
mkdir -p output/python

docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

docker run --rm -v "$PWD/output:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "cp -r /opt/python/. /output/python/"

cd output
zip -r ../lambda_layer.zip python
cd ..

rm -rf output/python

echo "Lambda layer zip created."
