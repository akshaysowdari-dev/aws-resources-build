pipeline {
    agent {
        docker {
            image 'python:3.11'
            args '-u root'  
        }
    }

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

                        apt-get update && apt-get install -y curl unzip awscli

                        # install terraform
                        curl -LO https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
                        unzip terraform_1.6.6_linux_amd64.zip
                        mv terraform /usr/local/bin/

                        # install terragrunt
                        curl -Lo /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64
                        chmod +x /usr/local/bin/terragrunt

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

                        aws s3 sync module/ s3://${PROJECT}-${TF_VAR_env}-${ACCOUNT_ID}-repo/module/ \
                            --exclude ".terragrunt-cache/*" \
                            --exclude "**/.terragrunt-cache/*" \
                            --exclude ".terraform/*" \
                            --exclude "**/.terraform/*" \
                            --exclude "*.tfstate*" \
                            --exclude ".git/*"
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

                        pip install --upgrade pip
                        pip install -r requirements.txt

                        python load_to_dynamodb.py
                    '''
                }
            }
        }
    }
}