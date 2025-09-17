# Dockerfile

FROM python:3.13-slim

# Set working directory
WORKDIR /opt

# Accept requirements.txt via build-arg
ARG REQ_FILE=requirements.txt

# Copy requirements.txt into image
COPY ${REQ_FILE} .

# Install dependencies to /opt/python
RUN pip install --no-deps --no-cache-dir -r requirements.txt -t python

# Clean up unwanted test and cache files (optional)
RUN find python/ -type d -iname "tests" -exec rm -rf {} + || true && \
    find python/ -type d -iname "__pycache__" -exec rm -rf {} + || true && \
    find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete || true

# Set environment path (optional, useful for debugging inside container)
ENV PYTHONPATH=/opt/python
