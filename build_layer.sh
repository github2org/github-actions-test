#!/bin/bash
set -e

PYTHON_VERSION="3.13"
LAYER_DIR="python/python/lib/python${PYTHON_VERSION}/site-packages"

echo "🧼 Cleaning previous build artifacts..."
rm -rf python lambda_layer.zip

echo "🐳 Building Docker image with Python ${PYTHON_VERSION} dependencies..."
docker buildx build --platform linux/amd64 \
  --build-arg REQ_FILE=requirements.txt \
  -t lambda-layer \
  --load .

echo "📦 Extracting dependencies from Docker container..."
docker run --rm -v "$PWD:/output" \
  --entrypoint /bin/bash \
  lambda-layer -c "mkdir -p /output/${LAYER_DIR} && cp -r /opt/python/* /output/${LAYER_DIR}"

# ✅ Verify that python directory exists
if [ ! -d "python" ]; then
  echo "❌ Error: python/ directory was not created. The layer may not contain any dependencies."
  echo "👉 Check your Dockerfile or requirements.txt to ensure packages are being installed into /opt/python."
  exit 1
fi

echo "🧹 Removing unnecessary files..."
find python/ -type d -iname "tests" -exec rm -rf {} + || true
find python/ -type d -iname "test" -exec rm -rf {} + || true
find python/ -type d -name "__pycache__" -exec rm -rf {} + || true
find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete || true
find python/ -type d -name "*.dist-info" -exec rm -rf {} + || true
find python/ -type d -name "*.egg-info" -exec rm -rf {} + || true

echo "📦 Creating lambda_layer.zip..."
cd python
zip -r ../lambda_layer.zip . > /dev/null
cd ..

echo "✅ Lambda layer package created: lambda_layer.zip"

# Optional cleanup
rm -rf python

echo "🎉 Done!"
