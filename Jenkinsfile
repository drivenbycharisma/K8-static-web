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

        // --- FIXED COMPILATION: INTERACTIVE PRODUCTION APPROVAL GATE ---
        stage('Production Approval Gate') {
            when {
                expression { 
                    return scm.branches[0].name.contains('main') 
                }
            }
            steps {
                script {
                    // Wrapped cleanly inside a script block to resolve compilation parameters
                    input message: "Do you want to deploy Build #${env.BUILD_NUMBER} to the Live Cluster?", ok: "Proceed Deployment"
                }
            }
        }

        stage('Deploy to K8s Cluster') {
            steps {
                sh "sed -i 's|image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest|image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' static-app.yaml"
                sh "kubectl apply -f static-app.yaml"
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
