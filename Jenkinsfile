pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate') {
            steps {
                bat 'terraform fmt -check -recursive'
                bat 'terraform init -input=false'
                bat 'terraform validate'
            }
        }

        stage('Security Scan') {
            steps {
                bat 'tflint --init'
                bat 'tflint --format compact'

                bat 'tfsec . --format junit --out tfsec-report.xml --soft-fail'
                bat 'tfsec . --minimum-severity HIGH'
            }

            post {
                always {
                    junit allowEmptyResults: true, testResults: 'tfsec-report.xml'
                }
            }
        }

        stage('Plan') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat 'terraform plan -out=tfplan'
                }

                archiveArtifacts artifacts: 'tfplan', fingerprint: true
            }
        }

        stage('Approval') {
            input {
                message 'Terraform plan completed. Do you want to apply these changes?'
                ok 'Apply Infrastructure'
            }
        }

        stage('Apply') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }

        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed - inspect the stage that went red.'
        }
    }
}