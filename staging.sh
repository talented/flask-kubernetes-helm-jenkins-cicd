#!/bin/bash

docker cp ./obmovies/dotini obmovies-staging:/app/.ini
docker exec obmovies-staging ls -la
docker exec obmovies-staging python run.py &


# this is already started dynamically in ci pipeline
# kept for local testing
# docker run -i --name obmovies-staging -d -v obmovies:/app \
# -p 5000:5000 fikircini/obm:latest