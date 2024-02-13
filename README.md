## Introduction
Deploy a basic application that responds with 'Hello World!' on the root path in a local Kubernetes environment using Helm. Then, expose the application to the internet using an Nginx Ingress Controller.

## Requirements
- Docker
- Node.js
- Helm
- Kubectl

## Containerize Application 
### Dockerfile
Creating a Dockerfile to containerize the application defining the necessary dependencies needed to run the application within a container.
```
1. FROM node:lts-alpine
2. RUN adduser -D appuser 
3. WORKDIR /usr/src/app
4. RUN chown -R appuser:appuser /usr/src/app
5. COPY package*.json .
6. RUN npm ci --only=production 
7. COPY . .
8. EXPOSE 3000
9. CMD ["node", "./app.js"]
```
In this Dockerfile:

1. Specifies the base image to use, which includes Node.js.
2. Creates a system user with no login shell.
3. Sets the working directory inside the container.
4. Changes ownership of the contents of '/usr/src/app' directory to appuser prevents security vulnerabilities.
5. Copies the package.json and package-lock.json files to the working directory.
6. Installs dependencies defined in package.json.
8. Exposes port 3000, which is the port the application listens on.
9. Specifies the command to run the application when the container starts.

### Build and Push Docker Image to container registry
- Docker login to the container registry
```
docker login <contianer_registry>
```
- Docker built with desired tag
```
docker build -f ./app/Dockerfile . -t <contianer_registry>/app:nodejs
```
- Push the docker image to the registry
```
docker push <contianer_registry>/app:nodejs
```
### Run a standalone container
- The application can be accessed at **http://localhost:3000**
```
docker run -d -p 3000:3000 <contianer_registry>/app:nodejs
```
## Install Nginx controller
Install NGINX Ingress Controller to make the application accessible from the internet.
```
1. kubectl create ns nginx-ingress
2. helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
3. helm repo update
4. helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.9.1 -n nginx-ingress --debug
```
1. Create a seperate namespace for the NGINX controller
2. Add Ingress-Nginx Helm chart into the local repository
3. Retrieve the most recent updates of the chart
4. Deploy the Ingress controller within the designated namespace

## Package the application using Helm
### Create helm chart
Use the command below to generate a Helm chart template. Modify the deployment, ingress, and service templates with the necessary attributes, and specify the desired values in the values.yaml file.
```
helm create nodejsapp
```
### Validate the changes
Helm lint checks for Kubernetes best practices and chart correctness in Helm charts.
**Note:** Run the above command from within the chart directory
```
cd helm_app/nodejsapp/
helm lint .
```
### Install chart
Customize the desired values in the values.yaml file, then use the following command to install the Helm chart.
```
helm install myapp ./helm_app/nodejsapp --namespace app --debug
```
### Update chart
Customize the desired values in the values.yaml file, then use the following command to upgrade the existing Helm chart.
```
helm upgrade myapp ./helm_app/nodejsapp -n app --debug
```
### Rollback chart
Rollback the chart to the previous version to undo the changes made during the upgrade.
- List the revision histroy for desired chart using below command
```
helm hist nodejsapp -n app
```
- Rollback to the desired version of the chart
```
helm rollback nodejsapp <version> -n app
```
## Destroy Application setup
- Delete the application related components 
```
helm delete myapp -n app
kubectl delete ns app
```
- Delete ingress controller related components 
```
helm delete ingress-nginx -n nginx-ingress
kubectl delete ns nginx-ingress
```
**NOTE:** If the namespace is stuck in a pending state, use the following command to delete it.
```
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n <namespace>
```

## Adapting the application for production environment:

- Configure Nginx Ingress to terminate SSL/TLS traffic and enforce secure communication with the application.
- Utilize the Horizontal Pod Autoscaler to dynamically scale the application based on incoming traffic, CPU, and memory metrics.
- Deploy the application in a multi-node, multi-AZ setup to ensure high availability and fault tolerance.
- Push container images to a highly available container registry like ECR to ensure reliability and availability of images and use image pull secrets in pods for secure access.
- Use node selectors to control which nodes the application pods are scheduled on, and use taints and tolerations for better control over node affinity.
- Specify security contexts for pods to enforce security measures such as runAsUser, runAsGroup, and capabilities restrictions.
- Utilize Kubernetes service accounts and IAM roles to control access to AWS resources and APIs from within the application pods.
- Employ a process manager like supervisord to manage application processes within containers for enhanced control and reliability in production Kubernetes environments.
