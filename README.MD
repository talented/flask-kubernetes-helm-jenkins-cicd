
# ob Movies

This is a short guide on setting up the system and environment dependencies
required for ob's Movies database.

#### **Your Mission**

Greetings Earthling! You have been selected to test your skills among the Team Awesome,
**DevOps** :)

This challenge contains a directory - `ob-devopsday/obmovies` - with a Python project and a mongoDB dataset dump
(available on the releases section of the repo). The package dependencies for Python are resolved using pip. The project
was built using Flask framework. The application has some errors/omissions that are purposefully made. Once you have
solved the connection issue run ``pytest`` to confirm
connectivity.

#### **Challenges**
1. Solve the following tickets/TODOs in `db.py`:
   1. Paging,
   1. Faceted Search and
   1. User Management.

    - [x] Completed! -> db.py updated and following tests have been run with success:
    * pytest -v -m connection
    * pytest -v -m connection_pooling
    * pytest -v -m paging
    * pytest -v -m facets
    * pytest -v -m faceted_search
    * pytest -v -m user_management

    These tests are also running in Jenkins Pipeline for a successfull CI process.

I chose Atlas cloud platform for the database connection in order to avoid extra work and high availability to be able to focus on my fully fledged solution with Kubernetes, Helm and CI/CD with Jenkins.

---
2. Containerize obmovies webapp and deploy into a Kubernetes solution/tool of your choice.
    
    - [x] Completed!
    - Application has been containerized by preparing a docker build with Dockerfile and also a Docker-compose file to be used for quick testing in development.
    - Kubernetes cluster has been created in minikube in an AWS EC2 instance. Deployment of the application is performed in a declarative way and by using shell scripts for automation. Related files can be found under kubernetes directory in the repository.

---
3. Use helm chart or daemonset templates to deploy the webapp.

    - [x] Completed!
    - A helm chart has been created with the name `obmovies-chart`. Templating capabilities of helm is heavily used by providing default values and adaptability of helm in a CI/CD process cycle have been tested and implemented properly.
---
##### **Brownie points:**
* Create a CICD pipeline to build the app and deploy to your cluster.

    - [x] Completed!
    - An almost complete CI/CD pipeline has been implemented with the following steps:
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

---

* Codify the creation of your cluster.

---
# Build and Deployment Instructions

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
- Run `docker-compose up -d` to start development container in detached mode. Application will be served in port 5000.

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

- Run `./kubernetes/deploy.sh` to deploy obmovies application with Kubernetes in default namespace.
Check that pods are running without any error:
```
kubectl get all -o wide
```
- You should be able to visit the running obmovies application from port 80 thanks to ingress controller.

## Helm
- Since port 80 is used by current Kubernetes deployment. It is required to stop it before. Run `./kubernetes/clean_all.sh` to have a clean state. 
- Adjust variables for your convenience in helm/values.yaml and install the chart by running:
```
helm install obmovies-chart ./helm/obmovies-chart
```
On each update, you have to ugrade to a new helm version by running:
```
helm upgrade obmovies-chart obmovies-chart --values ./helm/obmovies-chart/values.yaml
```
- Application is now available again on port 80

## CI/CD with Jenkins

### Prerequisites
- Ingress has to disabled because we will simulate the deployment with both pure Kubernetes and Helm in an automated process. There, they will be deployed to NodePorts respectively 32000 and 31000. 
- disable ingress file in helm template
```
mv ./helm/templates/h-obmovies-ingress.yaml ./helm/templates/h-obmovies-ingress.yaml.bak
```
- We will need to create a new minikube cluster with jenkins user. Stop and delete the current minikube by running:
 ```minikube delete```

- To interact with the Kubernetes cluster Jenkins will be executing the shell script with the Jenkins user, so the Jenkins user should have an administration(superuser) role assigned forehand.

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

- Run minikube inside jenkins user without ingress addons.

```minikube start --driver=none```

- Start jenkins and install the following plugins:
    - kubernetes
    -  docker
    - SSH Pipeline Steps
    - pipeline-utility-steps

- Add credentials for your github repository by creating an ssh key and add a web hook for push actions.

- Add credentials of your docker hub registry.

- Create a new job with type pipeline:
    - Check `Github hook trigger for GITscm polling` checkbox in Build Triggers
    - Copy and paste the content of `jenkins-pipeline.groovy` file into pipeline definition textbox as a pipeline script.

- Save and Run the job for testing.
- It will also start automatically for each git push and build the latest state of the application by also tagging it with the actual commit hash and deploy the application in Kubernetes and with helm concurrently.
- You can visit the obmovies app on ports 31000 with helm and port 32000 with Kubernetes deployment.  