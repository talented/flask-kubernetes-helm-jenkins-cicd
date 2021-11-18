#!/bin/bash

kubectl delete deployments.apps mflix
kubectl delete svc mflix-service 
kubectl delete configmap dotini 
kubectl delete ingress mflix-ingress 