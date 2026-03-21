pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set Env') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'develop') {
                        env.TF_VAR_env = 'dev'
                        env.AWS_CREDS = 'aws-dev-creds'
                    } 
                    else {
                        error "Unsupported branch: ${env.BRANCH_NAME}"
                    }

                    echo "Branch: ${env.BRANCH_NAME}"
                    echo "Env: ${env.TF_VAR_env}"
                    echo "AWS Creds: ${env.AWS_CREDS}"
                }
            }
        }

        stage('Deploy Infra') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDS
                ]]) {
                    sh '''
                        cd module/aws/dynamodb-table
                        terragrunt apply -auto-approve

                        cd ../s3-repo-replica
                        terragrunt apply -auto-approve
                    '''
                }
            }
        }

        stage('Upload Repo to S3') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDS
                ]]) {
                    sh '''
                        aws s3 sync . s3://repo-replica-$TF_VAR_env/
                    '''
                }
            }
        }

        stage('Load CSV to DynamoDB') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDS
                ]]) {
                    sh '''
                        cd module/aws/csv-to-dynamodb-job

                        pip install -r requirements.txt
                        python load_to_dynamodb.py
                    '''
                }
            }
        }

    }
}