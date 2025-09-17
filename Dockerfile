FROM python:3.13-slim 

WORKDIR /opt

ARG REQ_FILE=requirements.txt

COPY ${REQ_FILE} requirements.txt

RUN pip install --no-deps --no-cache-dir -r requirements.txt -t python/ && \
    rm -rf $(ls -d python/* | grep tests) || true && \
    rm -rf $(ls -d python/* | grep __pycache__) || true && \
    find python/ -name "*.py[co]" -delete || true