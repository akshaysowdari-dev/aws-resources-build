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

stage('Bootstrap Backend') {
    steps {
        withCredentials([
            [
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: env.AWS_CREDS
            ]
        ]) {
            sh '''
                ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                REGION="ap-south-2"

                BUCKET_NAME="akshay-${TF_VAR_env}-${ACCOUNT_ID}-tf-state"
                TABLE_NAME="tf-lock-${ACCOUNT_ID}"

                echo "Ensuring backend resources exist..."

                # Create S3 bucket if not exists
                if ! aws s3 ls s3://$BUCKET_NAME 2>/dev/null; then
                    aws s3 mb s3://$BUCKET_NAME --region $REGION
                fi

                # Create DynamoDB table if not exists
                if ! aws dynamodb describe-table --table-name $TABLE_NAME --region $REGION >/dev/null 2>&1; then
                    aws dynamodb create-table \
                        --table-name $TABLE_NAME \
                        --attribute-definitions AttributeName=LockID,AttributeType=S \
                        --key-schema AttributeName=LockID,KeyType=HASH \
                        --billing-mode PAY_PER_REQUEST \
                        --region $REGION
                fi
            '''
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
                        cd module/dynamodb-table
                        terragrunt apply -auto-approve

                        cd ../s3-repo-replica
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
                        aws s3 sync . s3://repo-replica-$TF_VAR_env/
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
                        cd module/csv-to-dynamodb-job

                        pip install -r requirements.txt
                        python load_to_dynamodb.py
                    '''
                }
            }
        }
    }
}