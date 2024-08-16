pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'eu-west-1'
    }
    stage('Grant Admin Access') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    script {
                        def clusterName = 'my-cluster'
                        sh """
                        aws eks update-kubeconfig --name ${clusterName} --region ${AWS_DEFAULT_REGION}
                        kubectl create clusterrolebinding jenkins-admin-binding \
                            --clusterrole=cluster-admin \
                            --user=arn:aws:iam::851725178273:user/Jenkins
                        """
                    }
                }
            }
        }
    }
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
       stage('Install Nginx') {
            steps {
                script {
                    dir('EKS/configuration-files') {
                        sh 'aws eks update-kubeconfig --name awake'
                        sh '''
                            kubectl create namespace nginx
                            kubectl apply -f nginx-deployment.yaml -n nginx
                            kubectl apply -f nginx-service.yaml -n nginx
                        '''
                    }
                }
            }
        }
    }
}