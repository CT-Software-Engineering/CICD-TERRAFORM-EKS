pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'eu-west-1'
        KUBECONFIG = "/var/lib/jenkins/workspace/Awake Pipeline/.kube/config"
    }

    stages {
        // Uncomment if needed
        // stage('Get AWS STS Identity') {
        //     steps {
        //         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AIDA4MTWG2WQ4544I3RJ6']]) {
        //             sh 'aws sts get-caller-identity'
        //         }
        //     }
        // }

        stage('Checkout SCM') {
            steps {
                script {
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/CT-Software-Engineering/CICD-TERRAFORM-EKS.git']])
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
                        // Uncomment if user confirmation is needed
                        // input(message: "Are you sure to proceed?", ok: "proceed")
                    }
                }
            }
        }

        stage('Creating/Destroying an EKS Cluster') {
            steps {
                script {
                    dir('EKS') {
                        // Uncomment the appropriate command
                        sh 'terraform apply --auto-approve'
                        // sh 'terraform destroy --auto-approve'
                    }
                }
            }
        }

        stage('Initializing Helm') {
            steps {
                script {
                    sh 'helm repo add bitnami https://charts.bitnami.com/bitnami'
                    sh 'helm repo update'
                    // Uncomment if you want to install Jenkins using Helm
                     sh "helm upgrade --install jenkins bitnami/jenkins --namespace awake --create-namespace --kubeconfig '${env.KUBECONFIG}'"
                }
            }
        }

        stage('Update Kubeconfig') {
            steps {
                script {
                    sh "aws eks update-kubeconfig --name awake --kubeconfig '${env.KUBECONFIG}'"
                    sh "cat '${env.KUBECONFIG}'"
                }
            }
        }

        stage('Check Permissions') {
            steps {
                script {
                    def kubeconfigPath = "/var/lib/jenkins/workspace/Awake Pipeline/.kube/config"

                    // Check file existence
                    if (fileExists(kubeconfigPath)) {
                        echo "kubeconfig file exists"
                    } else {
                        error "kubeconfig file does not exist"
                    }

                    // Check file permissions
                    sh "ls -l \"$kubeconfigPath\""

                    // Ensure the file is readable
                    sh "sudo chmod 644 \"$kubeconfigPath\""
                    sh "sudo chown jenkins:jenkins \"$kubeconfigPath\""

                    // Output kubeconfig file
                    sh "cat \"$kubeconfigPath\""
                }
            }
        }

        stage('Cluster Info') {
            steps {
                script {
                    sh 'kubectl --kubeconfig="/var/lib/jenkins/workspace/Awake Pipeline/.kube/config" cluster-info'
                }
            }
        }

        stage('Check kubeconfig') {
            steps {
                script {
                    sh "ls -l '${env.KUBECONFIG}'"
                }
            }
        }

        stage('Get Pods') {
            steps {
                script {
                    sh "kubectl get pods -n awake --kubeconfig '${env.KUBECONFIG}'"
                }
            }
        }

        stage('Deploying Jenkins') {
            steps {
                script {
                    sh "helm install jenkins bitnami/jenkins --namespace awake --create-namespace --kubeconfig '${env.KUBECONFIG}'"
                    // Uncomment to upgrade or uninstall
                    // sh "helm upgrade jenkins bitnami/jenkins --namespace awake --kubeconfig '${env.KUBECONFIG}'"
                    // sh "helm uninstall jenkins --namespace awake --kubeconfig '${env.KUBECONFIG}'"
                }
            }
        }

        stage('Verify Jenkins Deployment') {
            steps {
                script {
                    sh "kubectl get pods -n awake --kubeconfig '${env.KUBECONFIG}'"
                    sh "kubectl get svc -n awake --kubeconfig '${env.KUBECONFIG}'"
                }
            }
        }

        stage('Deploying NGINX') {
            steps {
                script {
                    dir('EKS/configuration-files') {
                        withCredentials([string(credentialsId: 'AWS_EKS_CLUSTER_NAME', variable: 'CLUSTER_NAME')]) {
                            echo "Cluster Name: \$CLUSTER_NAME"
                            sh 'aws eks describe-cluster --name $CLUSTER_NAME --region ${AWS_DEFAULT_REGION}'
                            sh 'aws eks update-kubeconfig --name $CLUSTER_NAME --kubeconfig "$KUBECONFIG"'
                            sh 'kubectl apply -f deployment.yml --kubeconfig "$KUBECONFIG" --validate=false'
                            sh 'kubectl apply -f service.yml --kubeconfig "$KUBECONFIG" --validate=false'
                        }
                    }
                }
            }
        }
    }
}
