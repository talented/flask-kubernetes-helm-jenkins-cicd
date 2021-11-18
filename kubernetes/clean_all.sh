#!/bin/bash

kubectl delete deployments.apps obmovies
kubectl delete svc obmovies-service 
kubectl delete configmap dotini 
kubectl delete ingress obmovies-ingress 