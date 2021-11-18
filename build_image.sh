#!/bin/bash

# change values below with yours
DOCKERHUB_USERNAME=username
IMAGE_NAME=mflix_movies
HASH=$(git rev-parse --short HEAD) # get latest commit hash
VERSION="${HASH:=latest}" # set latest if not a git repository

# build image
docker image build -f "mflix_movies/Dockerfile.prod" \
-t $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION ./mflix_movies

# push image to Dockerhub
# this line can be uncommented if you wish to run locally
docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION
