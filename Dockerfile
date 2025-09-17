FROM python:3.13-slim

WORKDIR /opt

ARG REQ_FILE=requirements.txt

COPY ${REQ_FILE} requirements.txt

RUN pip install --no-deps --no-cache-dir -r requirements.txt -t /opt/python/ && \
    rm -rf /opt/python/tests || true && \
    rm -rf /opt/python/**/__pycache__ || true && \
    find /opt/python/ -name "*.py[co]" -delete || true
