#!/bin/sh

# Delete the application related components 
helm delete myapp -n app
kubectl delete ns app

# Delete ingress controller 
helm delete ingress-nginx -n nginx-ingress
kubectl delete ns nginx-ingress