pipeline {
    agent any

    environment {
        TF_VAR_env = 'dev'
        AWS_CREDS = 'aws-dev-creds'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set Env') {
            steps {
                script {
                    echo "Env: ${env.TF_VAR_env}"
                    echo "AWS Creds: ${env.AWS_CREDS}"
                }
            }
        }

        stage('Deploy Infra') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDS
                    ]
                ]) {
                    sh '''
                        set -e

                        cd module/dynamodb-table
                        terragrunt init -reconfigure
                        terragrunt apply -auto-approve

                        cd ../s3-repo-replica
                        terragrunt init -reconfigure
                        terragrunt apply -auto-approve
                    '''
                }
            }
        }

        stage('Upload Repo to S3') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDS
                    ]
                ]) {
                    sh '''
                        set -e

                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        PROJECT=csvtodynamo

                        aws s3 sync . s3://${PROJECT}-${TF_VAR_env}-${ACCOUNT_ID}-repo
                    '''
                }
            }
        }

        stage('Load CSV to DynamoDB') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDS
                    ]
                ]) {
                    sh '''
                        set -e

                        cd module/csv-to-dynamodb-job
                        pip install -r requirements.txt
                        python load_to_dynamodb.py
                    '''
                }
            }
        }
    }
}