FROM python:3.9-alpine
WORKDIR /<github-repo>
ENV  MSG="Hello World!"
COPY . .
RUN pip3 install -r requirement.txt
EXPOSE 5000
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]