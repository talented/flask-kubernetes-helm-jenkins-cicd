pipeline {
    agent any
    environment {
        NAME = 'obmovies'
        REGISTRY = 'fikircini/obm'
        VERSION = getVersion()
        BUILD_FILE = './obmovies/Dockerfile.prod'
        BUILD_DIR = './obmovies'
        REGISTRY_CREDENTIAL = 'dockerhub'
        NS_NAME = 'helm'
    }
        
    stages {
        stage('SCM') {
            steps {
                git credentialsId: 'github',
                url: 'git@github.com:talented/obmovies.git' /* this is a private repository for testing */
            }
        }
        stage('Docker Build') {
            steps {
                sh "docker build -t ${REGISTRY}:${VERSION} -f ${BUILD_FILE} ${BUILD_DIR}"
            }
        }
        
        stage('Staging with Docker Container') {
            steps {
                sh "docker run -i --name ${NAME}-staging -d -v ${NAME}:/app -p 5000:5000 ${REGISTRY}:${VERSION}"
                sh "./staging.sh"
            }
        }
        
        stage('Running Tests in Staging') {
            steps {
                sh 'docker exec ${NAME}-staging pytest -v -m connection'
                sh 'docker exec ${NAME}-staging pytest -v -m connection_pooling'
                /* sh 'docker exec ${NAME}-staging pytest -v -m paging' */
                sh 'docker exec ${NAME}-staging pytest -v -m facets'
                sh 'docker exec ${NAME}-staging pytest -v -m faceted_search'
                sh 'docker exec ${NAME}-staging pytest -v -m user_management'
            }
        }
        
        stage('Remove Staging Container') {
            steps {
                deleteContainer() /* clean up our workspace */
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withDockerRegistry([ credentialsId: "${REGISTRY_CREDENTIAL}", url: "" ]) {
                    sh "docker push ${REGISTRY}:${VERSION}"
                }
            }
        }
        
        stage('Deployment with Kubernetes') {
            steps {
                sh './kubernetes/deploy_ci.sh ${VERSION}'
            }
        }
        
        stage('Deployment with Helm Chart') {
            steps {
                sh 'kubectl create namespace ${NS_NAME} --dry-run=client -o yaml | kubectl apply -f -'
                sh 'helm upgrade --install --set deployment.tag=${VERSION} ${NAME}-chart ./helm/${NAME}-chart'
            }
        }
    }
    
    post {
        always {
            echo 'One way or another, I have finished'
            deleteContainer() /* clean up our workspace */
        }
        success {
            echo 'I succeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
    }
    
}

def deleteContainer() {
    sh "docker stop ${NAME}-staging && docker rm ${NAME}-staging"
}

def getVersion() {
    def commitHash = sh (returnStdout: true, script: 'git rev-parse --short HEAD').trim()
    return commitHash
}