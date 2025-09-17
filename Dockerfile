FROM python:3.13-slim

WORKDIR /opt

ARG REQ_FILE=requirements.txt

COPY ${REQ_FILE} requirements.txt

RUN apt-get update && apt-get install -y gcc build-essential curl unzip && \
    pip install --no-deps --no-cache-dir -r requirements.txt -t /opt/python/ && \
    echo "== INSTALLED CONTENTS ==" && ls -al /opt/python && \
    rm -rf /opt/python/tests || true && \
    rm -rf /opt/python/**/__pycache__ || true && \
    find /opt/python/ -name "*.py[co]" -delete || true
