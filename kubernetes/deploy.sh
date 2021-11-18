#!/bin/bash

# replace with your local directory
PWD=/home/ubuntu/workspace/ob-devopsday/kubernetes

kubectl apply -f $PWD/obmovies-configmap.yaml

HASH=$(git rev-parse --short HEAD) # get latest commit hash
VERSION="${HASH:=latest}" # set latest if not a git repository
echo "export TAG=$VERSION" > .env
source .env

# apply the yml with the substituted value
envsubst < $PWD/obmovies-deployment.yaml | kubectl apply -f -

kubectl apply -f $PWD/obmovies-service.yaml
kubectl apply -f $PWD/obmovies-ingress.yaml

kubectl get all -o wide
