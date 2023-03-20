FROM python:slim
RUN groupadd flaskgroup && useradd -m -g flaskgroup -s /bin/bash flask
RUN echo "flask ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /home/flask/app/web
WORKDIR /home/flask/app/web
COPY . /home/flask/app/web
COPY *.py ./home/flask/app/web
COPY requirements.txt /home/flask/app/web
# RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y python3-pip

# # env vars
ARG DB_NAME 
ARG DB_USER 
ARG POSTGRES_DB
ARG POSTGRES_PASSWORD

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install -U gunicorn
RUN chown -R flask:flaskgroup /home/flask
USER flask
ENTRYPOINT ["gunicorn", "--bind", ":3000", "wsgi", "--reload", "--workers", "4"]