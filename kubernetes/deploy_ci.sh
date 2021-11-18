#!/bin/bash

# replace with your local directory
PWD="~/workspace/flask-kubernetes-helm-jenkins-cicd/kubernetes"

kubectl apply -f $PWD/mflix-configmap.yaml
echo "export TAG=$1" > /var/lib/jenkins/.env
source /var/lib/jenkins/.env

# apply the yml with the substituted value
envsubst < $PWD/mflix-deployment.yaml | kubectl apply -f -

kubectl apply -f $PWD/mflix-service.yaml
kubectl apply -f $PWD/mflix-ingress.yaml
kubectl get all -o wide
