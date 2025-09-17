FROM python:3.13-slim

WORKDIR /opt

ARG REQ_FILE=requirements.txt

COPY ${REQ_FILE} .

RUN pip install --no-cache-dir -r requirements.txt -t python

RUN find python/ -type d -iname "tests" -exec rm -rf {} + || true && \
    find python/ -type d -iname "__pycache__" -exec rm -rf {} + || true && \
    find python/ -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete || true
