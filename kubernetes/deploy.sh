#!/bin/bash

# replace with your local directory
PWD="~/workspace/flask-kubernetes-helm-jenkins-cicd/kubernetes"

kubectl apply -f $PWD/mflix-configmap.yaml

HASH=$(git rev-parse --short HEAD) # get latest commit hash
VERSION="${HASH:=latest}" # set latest if not a git repository
echo "export TAG=$VERSION" > .env
source .env

# apply the yml with the substituted value
envsubst < $PWD/mflix-deployment.yaml | kubectl apply -f -

kubectl apply -f $PWD/mflix-service.yaml
kubectl apply -f $PWD/mflix-ingress.yaml

kubectl get all -o wide
