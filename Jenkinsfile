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
                script {
                    // 1. Get Cluster Node Status formatted into an HTML string
                    def nodeStatus = sh(script: "kubectl get nodes -o wide", returnStdout: true).trim()
                    
                    // 2. Get Cluster Metrics (or placeholder if metrics-server isn't running)
                    def clusterMetrics = sh(script: "kubectl top nodes || echo 'Metrics engine initializing or unavailable...'", returnStdout: true).trim()

                    // 3. Inject the data into index.html dynamically before building the image
                    sh """
                    echo '<hr>' >> index.html
                    echo '<div style="margin-top: 20px; font-family: monospace; background: #222; color: #0f0; padding: 15px; border-radius: 5px; text-align: left; max-width: 800px; margin-left: auto; margin-right: auto; overflow-x: auto;">' >> index.html
                    echo '<h3>STAGE MONITORING: KUBERNETES LIVE NODE STATUS</h3>' >> index.html
                    echo '<pre>${nodeStatus}</pre>' >> index.html
                    echo '<h3>STAGE MONITORING: CLUSTER CPU & MEMORY METRICS</h3>' >> index.html
                    echo '<pre>${clusterMetrics}</pre>' >> index.html
                    echo '</div>' >> index.html
                    """
                }
                // 4. Build and tag the updated image containing the live text data
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
