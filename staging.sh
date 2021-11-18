#!/bin/bash

docker cp ./mflix_movies/dotini mflix_movies-staging:/app/.ini
docker exec mflix_movies-staging ls -la
docker exec mflix_movies-staging python run.py &


# this is already started dynamically in ci pipeline
# kept for local testing
# docker run -i --name mflix_movies-staging -d -v mflix_movies:/app \
# -p 5000:5000 dockerhub_username/mflix_movies:latest