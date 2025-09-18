FROM python:3.13

WORKDIR /opt

ARG REQ_FILE=requirements.txt

COPY ${REQ_FILE} requirements.txt

RUN pip install --no-deps --no-cache-dir -r requirements.txt -t /opt/python && \
    rm -rf $(ls -d /opt/python/* | grep tests) || true && \
    rm -rf $(ls -d /opt/python/* | grep __pycache__) || true && \
    find /opt/python -name "*.py[co]" -delete || true

