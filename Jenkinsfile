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
                        S3_BUCKET="${var.project}-${var.env}-${var.account_id}-repo-adjusted"

                        aws s3 sync . s3://${S3_BUCKET}/ \
                            --exclude ".terragrunt-cache/*" \
                            --exclude ".git/*" \
                            --exclude ".gitignore" \
                            --exclude ".github/*" \
                            --exclude "**/.terragrunt-cache/*" \
                            --exclude ".terraform/*" \
                            --exclude "**/.terraform/*" \
                            --exclude "*.tfstate*"
                            --exclude "*.tfvars" \
                            --exclude "node_modules/*" \
                            --exclude ".DS_Store" \
                            --exclude "*.backup"
                    '''
                }
            }
        }

        // stage('Load CSV to DynamoDB') {
        //     steps {
        //         withCredentials([
        //             [
        //                 $class: 'AmazonWebServicesCredentialsBinding',
        //                 credentialsId: env.AWS_CREDS
        //             ]
        //         ]) {
        //             sh '''
        //                 set -e

        //                 cd module/csv-to-dynamodb-job
                        
        //                 command -v pip3 || (apt-get update && apt-get install -y python3-pip)
                        
        //                 python3 -m pip install --upgrade pip
        //                 python3 -m pip install -r requirements.txt

        //                 python3 load_to_dynamodb.py
        //             '''
        //         }
        //     }
        // }
    }
}


