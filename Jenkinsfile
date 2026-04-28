pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'  // Set default AWS region
    }

    stages {
        // Checkout Code
        stage('Checkout') {
            steps {
                git branch: 'feature', 
                    credentialsId: '33e5e605-33c2-45d2-8c7d-4a94a80eb1ef', 
                    url: 'https://github.com/KandlaguntaVenkataSivaNiranjanReddy/spring-boot-mongo-docker-kkfunda.git'
            }
        }

        // Build the Maven Project
        stage('Build') {
            steps {
                sh "mvn clean package"
            }
        }

        // File System Security Scan using Trivy
        stage('File System Trivy Scan') {
            steps {
                script {
                    def status = sh(script: "trivy fs --format table -o trivy-fs-report.html .", returnStatus: true)
                    if (status != 0) {
                        error "Trivy scan failed with exit code ${status}"
                    } else {
                        echo "Trivy scan completed successfully."
                    }
                }
            }
        }

        // Code Quality Analysis with SonarQube
        stage('SonarQube') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                    mvn sonar:sonar \
                        -Dsonar.projectKey=spring-boot-mongo \
                        -Dsonar.projectName='Spring Boot Mongo Project' \
                        -Dsonar.host.url=http://18.175.240.114:9000/
                    """
                }
            }
        }

        // Build Docker Image and Tag
        stage('Build & Tag Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: '985fdb56-2bc9-4fc7-b69d-0c3dfddee456') {
                        sh "docker build -t niranjanreddy1231/mongospring:latest ."
                    }
                }
            }
        }

        // Push Docker Image to Registry
        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: '985fdb56-2bc9-4fc7-b69d-0c3dfddee456') {
                        sh "docker push niranjanreddy1231/mongospring:latest"
                    }
                }
            }
        }

        // Configure AWS EKS Access
        stage('Setup KubeConfig') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-eks-cred']]) {
                    script {
                        sh """
                        aws eks update-kubeconfig --region ap-south-1 --name EKS-Demo
                        """
                    }
                }
            }
        }

        // Deploy to Kubernetes Cluster
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-eks-cred']]) {
                    script {
                        sh """
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        kubectl apply -f springappmongo.yaml -n test-ns --validate=false
                        """
                    }
                }
            }
        }

        // Verify Deployed Pods
        stage('Verify Pods') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-eks-cred']]) {
                    script {
                        sh "kubectl get pods -n test-ns"
                    }
                }
            }
        }
    }
}
