#!/bin/bash

# change values below with yours
DOCKERHUB_USERNAME=fikircini
IMAGE_NAME=obm
HASH=$(git rev-parse --short HEAD) # get latest commit hash
VERSION="${HASH:=latest}" # set latest if not a git repository

# build image
docker image build -f "obmovies/Dockerfile.prod" \
-t $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION ./obmovies

# push image to Dockerhub
# this line can be uncommented if you wish to run locally
docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION
