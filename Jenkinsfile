pipeline {
    agent any

    environment {
        TF_STATE = '/var/lib/jenkins/terraform-state/terraform.tfstate'
        AWS_PROFILE = 'academy'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform fmt -check'
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -state=$TF_STATE -out=tfplan'
            }
        }

        stage('Approval') {
            steps {
                input message: 'Autoriser le déploiement Terraform ?', ok: 'Déployer'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -state=$TF_STATE -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
        }
    }
}
