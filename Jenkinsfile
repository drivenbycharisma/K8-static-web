pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = 'asmichugh55677'  
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

        // --- NEW: INTERACTIVE PRODUCTION APPROVAL GATE ---
        stage('Production Approval Gate') {
            when {
                branch 'main' // This verification gate only pauses builds executing on the main production branch
            }
            steps {
                input {
                    message "Do you want to deploy Build #${env.BUILD_NUMBER} to the Live Cluster?"
                    ok "Proceed Deployment"
                    submitter "admin,jenkins-admin" // Optional security constraint
                }
            }
        }

        stage('Deploy to K8s Cluster') {
            steps {
                // Modifies configuration and applies the new Zero-Downtime strategy rolling update rules
                sh "sed -i 's|image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest|image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' static-app.yaml"
                sh "kubectl apply -f static-app.yaml"
                
                // Tracks the rolling update status live in the terminal output logs
                sh "kubectl rollout status deployment/static-web-deployment --timeout=60s"
            }
        }

        stage('Live Cluster Monitor') {
            steps {
                script {
                    echo "========================================="
                    echo "      KUBERNETES LIVE NODE STATUS        "
                    echo "========================================="
                    sh 'kubectl get nodes -o wide || true'
                    
                    echo "========================================="
                    echo "      CLUSTER CPU & MEMORY METRICS       "
                    echo "========================================="
                    sh 'kubectl top nodes || echo "Metrics engine initializing..."'
                }
            }
        }
    }
}
