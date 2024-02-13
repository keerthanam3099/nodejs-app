#!/bin/sh

# Build and push dockerfile 
docker login
docker build -f ./app/Dockerfile . -t keerthy99/app:nodejs
docker push keerthy99/app:nodejs

# Test application docker 
docker run -d -p 3000:3000 keerthy99/app:nodejs

# Helm install nginx-operator
kubectl create ns nginx-ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.9.1 -n nginx-ingress --debug

# Helm install application
kubectl create ns app
helm install myapp ./helm_app/nodejsapp -n app --debug