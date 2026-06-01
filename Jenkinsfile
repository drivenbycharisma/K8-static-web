pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = 'asmichugh55677'  // Updated with your username!
        IMAGE_NAME      = 'static-web-app'
        IMAGE_TAG       = "${BUILD_NUMBER}"
    }

    stages {
        stage('Pull SCM Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'PASSWORD', usernameVariable: 'USER')]) {
                    sh "echo \$PASSWORD | docker login -u \$USER --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to K8s Cluster') {
            steps {
                sh "sed -i 's|image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest|image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' static-app.yaml"
                sh "kubectl apply -f static-app.yaml"
            }
        }
    }
}
stage('Live Cluster Monitor') {
            steps {
                script {
                    echo "--- NODE HEALTH & IP ADDRESSES ---"
                    sh 'kubectl get nodes -o wide'
                    
                    echo "--- RESOURCE USAGE (CPU/MEM) ---"
                    sh 'kubectl top nodes || echo "Metrics server not found"'
                    
                    echo "--- RUNNING SERVICES ---"
                    sh 'kubectl get svc'
                }
            }
        }
