#!/bin/bash

# replace with your local directory
PWD=/home/ubuntu/workspace/ob-devopsday/kubernetes

kubectl apply -f $PWD/obmovies-configmap.yaml
echo "export TAG=$1" > /var/lib/jenkins/.env
source /var/lib/jenkins/.env

# apply the yml with the substituted value
envsubst < $PWD/obmovies-deployment.yaml | kubectl apply -f -

kubectl apply -f $PWD/obmovies-service.yaml
kubectl apply -f $PWD/obmovies-ingress.yaml
kubectl get all -o wide
