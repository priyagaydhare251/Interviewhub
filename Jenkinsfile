pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:

  - name: node
    image: node:18
    command: ['cat']
    tty: true

  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command: ['cat']
    tty: true

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true
    securityContext:
      runAsUser: 0
      readOnlyRootFilesystem: false
    env:
      - name: KUBECONFIG
        value: /kube/config
    volumeMounts:
      - name: kubeconfig-secret
        mountPath: /kube/config
        subPath: kubeconfig

  - name: dind
    image: docker:dind
    args: ["--storage-driver=overlay2"]
    securityContext:
      privileged: true
    env:
      - name: DOCKER_TLS_CERTDIR
        value: ""

  volumes:
    - name: kubeconfig-secret
      secret:
        secretName: kubeconfig-secret
'''
        }
    }

    environment {
        NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY = "pk_test_dml0YWwtbXVkZmlzaC02LmNsZXJrLmFjY291bnRzLmRldiQ"
        NEXT_PUBLIC_CLERK_FRONTEND_API   = "vital-mudfish-6.clerk.accounts.dev"
        NEXT_PUBLIC_CONVEX_URL           = "https://flippant-goshawk-377.convex.cloud"
        NEXT_PUBLIC_STREAM_API_KEY       = "muytsbs2rpay"
        NEXT_PUBLIC_DISABLE_CONVEX_PRERENDER = "true"

        REGISTRY = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
    }

    stages {

        stage('Install + Build Frontend') {
            steps {
                container('node') {
                    sh '''
                        npm install
                        npm run build
                    '''
                }
            }
        }

        /* =============================================
           NEW: LOGIN TO DOCKER HUB TO AVOID 429 ERROR
        ============================================== */

        stage('Docker Hub Login') {
            steps {
                container('dind') {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-cred',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )]) {
                        sh '''
                            echo "$PASS" | docker login -u "$USER" --password-stdin
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {
                    sh '''
                        sleep 10
                        docker build \
                            --build-arg NEXT_PUBLIC_CONVEX_URL="https://flippant-goshawk-377.convex.cloud" \
                            --build-arg NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_test_dml0YWwtbXVkZmlzaC02LmNsZXJrLmFjY291bnRzLmRldiQ" \
                            --build-arg NEXT_PUBLIC_STREAM_API_KEY="muytsbs2rpay" \
                            -t interviewhub-app:latest .
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('sonar-scanner') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            sonar-scanner \
                                -Dsonar.token=$SONAR_TOKEN \
                                -Dsonar.host.url=http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000
                        '''
                    }
                }
            }
        }

        stage('Login to Nexus Registry') {
             steps {
                 container('dind') {
                     sh '''
                         docker login nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085 -u admin -p Changeme@2025
                     '''
                 }
             }
         }

         stage('Push to Nexus') {
             steps {
                 container('dind') {
                     sh '''
                         docker tag interviewhub-app:latest nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/2401054/interviewhub:v1
                         docker push nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/2401054/interviewhub:v1
                     '''
                 }
             }
        }

        stage('Create Namespace') {
            steps {
                container('kubectl') {
                    sh '''
                        echo "Ensuring namespace 2401054 exists..."
                        kubectl get namespace 2401054 || kubectl create namespace 2401054
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                        echo "Deploying to Kubernetes Namespace: 2401054"

                        kubectl apply -f k8s/deployment.yaml -n 2401054
                        kubectl apply -f k8s/service.yaml -n 2401054

                        echo "Resources in namespace 2401054:"
                        kubectl get all -n 2401054
                    '''
                }
            }
        }

        stage('Show Cluster Nodes & Service Info') {
            steps {
                container('kubectl') {
                    sh '''
                        echo "===== Kubernetes Nodes ====="
                        kubectl get nodes -o wide

                        echo ""
                        echo "===== Services in namespace 2401054 ====="
                        kubectl get svc -n 2401054

                        echo ""
                        echo "If service shows NodePort, open:"
                        echo "http://<NODE-IP>:<NODEPORT>"
                    '''
                }
            }
        }
    }
}
