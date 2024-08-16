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
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/CT-Software-Engineering/CICD-TERRAFORM-EKS.git']])
                }
            }
        }
         stage('Initializing Terraform'){
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform init'
                    }
                }
            }
        }
        stage('Formating terraform code'){
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform fmt -recursive'
                    }
                }
            }
        }
        stage('Validating Terraform'){
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform validate'
                    }
                }
            }
        }
        stage('Previewing the infrastructure'){
            steps{
                script{
                    dir('EKS'){
                         sh 'terraform plan'
                    }
                    //input(message: "Are you sure to proceed?", ok: "proceed")
                }
            }
        }
        stage('Creating/Destroying an EKS cluster'){
            steps{
                script{
                    dir('EKS'){
                         //sh 'terraform $action --auto-approve'
                         sh 'terraform apply --auto-approve'
                         //sh 'terraform destroy --auto-approve'
                    }
                }
            }
        }
       stage('Deploying Nginx') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-id' // Use the ID you set when adding the credentials
                ]]) {
                    script {
                        dir('EKS/configuration-files') {
                            sh 'aws eks update-kubeconfig --name awake'
                            sh 'kubectl apply -f deployment.yml --validate=false'
                            sh 'kubectl apply -f service.yml --validate=false'
                        }
                    }
                }
            }
        }
    }
}