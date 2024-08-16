pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'eu-west-1'
    }

    stages {
        
        
        
        stage('Checkout SCM') {
            steps {
                script {
                    checkout scmGit(
                        branches: [[name: '*/main']],
                        extensions: [],
                        userRemoteConfigs: [[url: 'https://github.com/CT-Software-Engineering/CICD-TERRAFORM-EKS.git']]
                    )
                }
            }
        }
        
        stage('Initializing Terraform') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform init'
                    }
                }
            }
        }
        
        stage('Formatting Terraform Code') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform fmt -recursive'
                    }
                }
            }
        }
        
        stage('Validating Terraform') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform validate'
                    }
                }
            }
        }
        
        stage('Previewing the Infrastructure') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform plan'
                        // input(message: "Are you sure to proceed?", ok: "proceed")
                    }
                }
            }
        }
        
        stage('Creating/Destroying an EKS Cluster') {
            steps {
                script {
                    dir('EKS') {
                        // sh 'terraform $action --auto-approve'
                        sh 'terraform apply --auto-approve'
                        //sh 'terraform destroy --auto-approve'
                    }
                }
            }
        }
        
        stage('Initializing Helm') {
            steps {
                script {
                    sh 'helm repo add bitnami https://charts.bitnami.com/bitnami'
                    sh 'helm repo update'
                }
            }
        }
        stage('Update Kubeconfig') {
            steps {
                script {
                    sh 'aws eks update-kubeconfig --name awake --kubeconfig "/var/lib/jenkins/workspace/EKS CICD/.kube/config"'
                }
            }
        }
        stage('Deploying Jenkins') {
            steps {
                script {
                    sh 'helm install jenkins bitnami/jenkins --namespace awake-namespace --create-namespace --kubeconfig "/var/lib/jenkins/workspace/EKS CICD/.kube/config"'
                }
            }
        }
        stage('Verify Jenkins Deployment') {
            steps {
                script {
                    sh 'kubectl get pods -n awake-namespace --kubeconfig "$KUBECONFIG"'
                    sh 'kubectl get svc -n awake-namespace --kubeconfig "$KUBECONFIG"'
                }
            }
        }

        /*stage('Install Nginx') {
            steps {
                script {
                    dir('EKS/configuration-files') {
                        sh 'aws eks update-kubeconfig --name awake'
                        sh '''
                            kubectl create namespace nginx
                            kubectl apply -f nginx-deployment.yaml -n nginx
                            kubectl apply -f nginx-service.yaml -n nginx
                        '''
                    }*/
                }
            }
        }
    }
}
