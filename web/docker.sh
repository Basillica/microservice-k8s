#!/bin/bash

export DOCKER_DEFAULT_PLATFORM=linux/amd64
docker build -t flask-api .
docker tag flask-api basillica/flask-api:v1
docker push basillica/flask-api:v1