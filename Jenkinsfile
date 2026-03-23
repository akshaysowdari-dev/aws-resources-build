pipeline {
    agent any

    environment {
        TF_VAR_env = 'dev'
        AWS_CREDS = 'aws-dev-creds'
        PROJECT = 'csvtodynamo'
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
                        
                        # Clean cache (VERY IMPORTANT)
                        rm -rf .terragrunt-cache

                        cd module/dynamodb-table
                        terragrunt init -reconfigure
                        terragrunt apply -auto-approve

                        cd ../../

                        cd module/s3-repo-replica
                        terragrunt init -reconfigure
                        terragrunt apply -auto-approve

                        cd ../../

                        cd module/csv-to-dynamodb-job
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
                        S3_BUCKET="${PROJECT}-${TF_VAR_env}-${ACCOUNT_ID}-repo"

                        aws s3 sync . s3://${S3_BUCKET}/ \
                            --exclude ".terragrunt-cache/*" \
                            --exclude ".git/*" \
                            --exclude ".gitignore" \
                            --exclude ".github/*" \
                            --exclude "**/.terragrunt-cache/*" \
                            --exclude ".terraform/*" \
                            --exclude "**/.terraform/*" \
                            --exclude "*.tfstate*" \
                            --exclude "*.tfvars" \
                            --exclude "node_modules/*" \
                            --exclude ".DS_Store" \
                            --exclude "*.backup"
                    '''
                }
            }
        }

        stage('Upload CSV to S3') {
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
                        S3_BUCKET="${PROJECT}-${TF_VAR_env}-${ACCOUNT_ID}-store-csv"

                        aws s3 cp unemployment_rate_by_age_groups.csv \
                        s3://${S3_BUCKET}/
                    '''
                }
            }
        }
    }
}