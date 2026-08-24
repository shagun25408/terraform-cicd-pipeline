pipeline {
    agent any

    triggers {
        // Checks GitHub for changes approximately every 5 minutes
        // Useful because your Jenkins is running locally and GitHub
        // cannot directly reach localhost for webhooks.
        pollSCM('H/5 * * * *')
    }

    environment {
        TF_IN_AUTOMATION = 'true'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate') {
            steps {
                bat 'terraform fmt -check -recursive -diff'
                bat 'terraform init -input=false'
                bat 'terraform validate'
            }
        }

        stage('Security Scan') {
            steps {
                // Initialize TFLint
                bat 'tflint --init'

                // Run Terraform linting
                bat 'tflint --format compact'

                // Generate a security report for Jenkins
                bat 'tfsec . --format junit --out tfsec-report.xml --soft-fail'

                // Fail the pipeline if HIGH severity issues are found
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
                bat 'terraform plan -out=tfplan'

                // Archive the Terraform plan as a Jenkins artifact
                archiveArtifacts artifacts: 'tfplan', fingerprint: true
            }
        }

        stage('Approval') {
            steps {
                input message: 'Terraform plan is ready. Approve infrastructure deployment?'
            }
        }

        stage('Apply') {
            steps {
                bat 'terraform apply -auto-approve tfplan'
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