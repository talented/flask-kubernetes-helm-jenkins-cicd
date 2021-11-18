
# **Mflix movies deployment - Kubernetes - Helm - CI/CD with Jenkins**

This is a guide on setting up the system for mflix movies mongodb sample database and deployment with Kubernetes and Helm. An almost complete CI/CD pipeline is also added with Jenkins. 


## Steps
1. Please follow the guide to connect the mongodb database with mflix sample db on Atlas Cloud:
https://github.com/dscarlat/m220

2. Run a few test to check the connection:
    * pytest -v -m connection
    * pytest -v -m connection_pooling
    * pytest -v -m paging
    * pytest -v -m facets
    * pytest -v -m faceted_search
    * pytest -v -m user_management
<br><br>

    These tests are also running in Jenkins Pipeline for a successfull CI process.

---
3. Application has been containerized by preparing a docker build with Dockerfile and also a Docker-compose file to be used for quick testing in development.

---

4. Kubernetes cluster has been created in minikube in an AWS EC2 instance. Deployment of the application is performed in a declarative way and by using shell scripts for automation. Related files can be found under kubernetes directory in the repository.

---
5. A helm chart has been created with the name `mflix-chart`. Templating capabilities of helm is heavily used by providing default values and adaptability of helm in a CI/CD process cycle have been tested and implemented properly.
---
6. An almost complete CI/CD pipeline has been implemented with the following steps:
    - SCM -> clone the repository
    - Build Docker image
    - Create a docker container for staging
    - Run the tests in staging container
    - Remove the container
    - Push image to Docker Hub
    - Deployment with Kubernetes
    - Deployment with Helm
    
    Tagging of the images is done by using the commit hash automatically.

    ![Jenkins Pipeline](jenkins.png)


<br><br>
# **Build and Deployment Instructions**

Current Deployment is performed on a Ubuntu 20.04.2 LTS AWS EC2 instance t2.medium with 2CPU and 4GB RAM.

## Prerequisities:
- [Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)
- [Docker-compose](https://docs.docker.com/compose/install/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Jenkins](https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-20-04)

## Docker build and Docker-compose

- Modify and run `build_image.sh` script with your username and a given imagename. If you want to push it docker hub, run `docker login` with your docker hub credentials. If you are in a github repository, a tag with git commit hash will be added as the image tag.
- Run `docker-compose up -d` to start development container in detached mode. Application will be ready in port 80 by the help of nginx as a reverse proxy.

## Minikube

- Start minikube driverless mode with ingress addons.

```
# install the following packages to make ingress work properly in a minikube cluster
apt install socat
apt install conntrack

# start minikube
minikube start --driver=none --addons=ingress

# check the status
minikube status
``` 
## Kubernetes

- Run `./kubernetes/deploy.sh` to deploy mflix_movies application with Kubernetes in default namespace.
Check that pods are running without any error:
```
kubectl get all -o wide
```
- You should be able to visit the running mflix_movies application from port 80 thanks to ingress controller.
<br><br>
## Helm
- Since port 80 is used by current Kubernetes deployment. It is required to stop it before. Run `./kubernetes/clean_all.sh` to have a clean state. 
- Adjust variables for your convenience in helm/values.yaml and install the chart by running:
```
helm install mflix-chart ./helm/mflix-chart
```
On each update, you have to ugrade to a new helm version by running:
```
helm upgrade mflix-chart mflix-chart --values ./helm/mflix-chart/values.yaml
```
- Application is now available again on port 80
<br><br>

## CI/CD with Jenkins

### Prerequisites
- We will need to create a new minikube cluster with jenkins user. Stop and delete the current minikube by running:
 ```minikube delete```

- To interact with the Kubernetes cluster Jenkins will be executing the shell script with the Jenkins user, so the Jenkins user should have an administrator(superuser) role assigned forehand.

    Let’s add jenkins user as an administrator and also ass NOPASSWD so that during the pipeline run it will not ask for root password.

    - Open the file /etc/sudoers in vi mode

        ```sudo vi /etc/sudoers``` 

    - Add the following line at the end of the file

        ```jenkins ALL=(ALL) NOPASSWD: ALL```

    - After adding the line save and quit the file.

    - Now we can use Jenkins as root user and for that run the following command:

        ```sudo su - jenkins``` 
---

### CI/CD Setup

- Run minikube inside jenkins user with ingress addons.

```minikube start --driver=none --addons=ingress```

- Start jenkins and install the following plugins:
    - kubernetes
    - docker
    - SSH Pipeline Steps
    - pipeline-utility-steps

- Add credentials for your github repository by creating an ssh key and add a web hook for push actions.

- Add credentials of your docker hub registry.

- Create a new job with type pipeline:
    - Check `Github hook trigger for GITscm polling` checkbox in Build Triggers
    - Copy and paste the content of `jenkins-pipeline.groovy` file into pipeline definition textbox as a pipeline script.

- Save and Run the job for testing.
- It will also start automatically for each git push and build the latest state of the application by also tagging it with the actual commit hash and deploy the application in Kubernetes and with helm concurrently.
- You can visit the mflix_movies app on port 80 and also ports 31000 with helm and port 32000 with Kubernetes deployment.