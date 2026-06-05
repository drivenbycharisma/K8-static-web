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

        // --- FIXED: AUTOMATED PRODUCTION APPROVAL GATE ---
        stage('Production Approval Gate') {
            when {
                expression { 
                    // Safely inspects the checked-out branch name directly from the Git SCM tree metadata
                    return scm.branches[0].name.contains('main') 
                }
            }
            steps {
                input {
                    message "Do you want to deploy Build #${env.BUILD_NUMBER} to the Live Cluster?"
                    ok "Proceed Deployment"
                }
            }
        }

        stage('Deploy to K8s Cluster') {
            steps {
                // Modifies the app configuration to map the fresh image tag
                sh "sed -i 's|image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest|image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' static-app.yaml"
                
                // Applies changes utilizing our zero-downtime health probe strategy rules
                sh "kubectl apply -f static-app.yaml"
                
                // Monitors the rolling update execution progress live in your console logs
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
