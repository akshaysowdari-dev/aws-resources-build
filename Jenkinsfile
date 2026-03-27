pipeline {
    agent any

    environment {
        PROJECT = 'csvtodynamo'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set Environment') {
            steps {
                script {
                    echo "Branch: ${env.BRANCH_NAME}"

                    env.DEPLOY_ENV = getEnvFromBranch(env.BRANCH_NAME)

                    if (env.DEPLOY_ENV == null) {
                        error "Invalid branch for deployment"
                    }

                    env.AWS_CREDS = getAwsCreds(env.DEPLOY_ENV)

                    withAwsCredentials {
                        env.ACCOUNT_ID = sh(
                            script: 'aws sts get-caller-identity --query Account --output text',
                            returnStdout: true
                        ).trim()
                    }

                    echo "Deploying to: ${env.DEPLOY_ENV}"
                    echo "Using AWS creds: ${env.AWS_CREDS}"
                    echo "Account ID: ${env.ACCOUNT_ID}"
                }
            }
        }

        stage('Validate Tools') {
            steps {
                sh '''
                    set -e
                    command -v aws
                    command -v terragrunt
                '''
            }
        }

        stage('Bootstrap Backend') {
            steps {
                script {
                    withAwsCredentials {
                        bootstrapBackend(env.DEPLOY_ENV)
                    }
                }
            }
        }

        stage('Deploy Infrastructure') {
            steps {
                script {
                    withAwsCredentials {
                        deployAllModules(env.DEPLOY_ENV)
                    }
                }
            }
        }

        stage('Post Deploy') {
            steps {
                script {
                    withAwsCredentials {
                        parallel(
                            "Upload Repo": {
                                uploadRepo(env.DEPLOY_ENV)
                            },
                            "Upload CSV": {
                                uploadCSV(env.DEPLOY_ENV)
                            }
                        )
                    }
                }
            }
        }
    }
}

def getEnvFromBranch(branch) {
    switch(branch) {
        case 'develop':
            return 'dev'
        case 'test':
            return 'qa'
        case 'main':
        case 'release':
            return 'prod'
        default:
            return null
    }
}

def getAwsCreds(environment) {
    switch(environment) {
        case 'dev':
            return 'aws-dev-creds'
        case 'qa':
            return 'aws-qa-creds'
        case 'prod':
            return 'aws-prod-creds'
        default:
            error "No AWS credentials mapped for ${environment}"
    }
}

def withAwsCredentials(body) {
    withCredentials([
        [
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: env.AWS_CREDS
        ]
    ]) {
        body()
    }
}

def bootstrapBackend(environment) {
    sh """
        set -e

        REGION="ap-south-2"
        ACCOUNT_ID=${env.ACCOUNT_ID}
        ENV=${environment}

        BUCKET="akshay-\${ENV}-\${ACCOUNT_ID}-tf-state-001"
        TABLE="tf-lock-\${ENV}-\${ACCOUNT_ID}"

        echo "===== BOOTSTRAP START ====="

        echo "Checking S3 bucket: \$BUCKET"

        if aws s3api head-bucket --bucket \$BUCKET 2>/dev/null; then
            echo "S3 bucket exists"
        else
            echo "Creating S3 bucket..."

            aws s3 mb s3://\$BUCKET --region \$REGION

            aws s3api put-bucket-versioning \
                --bucket \$BUCKET \
                --versioning-configuration Status=Enabled

            echo "S3 bucket created with versioning enabled"
        fi

        echo "Checking DynamoDB table: \$TABLE"

        if aws dynamodb describe-table --table-name \$TABLE --region \$REGION 2>/dev/null; then
            echo "DynamoDB table exists"
        else
            echo "Creating DynamoDB table..."

            aws dynamodb create-table \
                --table-name \$TABLE \
                --attribute-definitions AttributeName=LockID,AttributeType=S \
                --key-schema AttributeName=LockID,KeyType=HASH \
                --billing-mode PAY_PER_REQUEST \
                --region \$REGION

            aws dynamodb wait table-exists \
                --table-name \$TABLE \
                --region \$REGION

            echo "DynamoDB table created"
        fi

        echo "===== BOOTSTRAP COMPLETE ====="
    """
}

def deployAllModules(environment) {
    sh """
        set -e

        export TF_VAR_env=${environment}
        export AWS_ACCOUNT_ID=${env.ACCOUNT_ID}

        rm -rf .terragrunt-cache

        terragrunt run --all apply -- -auto-approve
    """
}

def uploadRepo(environment) {
    sh """
        set -e

        S3_BUCKET="${PROJECT}-${environment}-${env.ACCOUNT_ID}-repo"

        aws s3 sync . s3://\${S3_BUCKET}/ \
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
            --exclude "*.backup" \
            --only-show-errors
    """
}

def uploadCSV(environment) {
    sh """
        set -e

        S3_BUCKET="${PROJECT}-${environment}-${env.ACCOUNT_ID}-store-csv"

        CSV_FILE="unemployment_rate_by_age_groups.csv"

        if [ -f "$CSV_FILE" ]; then
            aws s3 cp $CSV_FILE s3://\${S3_BUCKET}/ --only-show-errors
        else
            echo "CSV file not found, skipping upload"
        fi
    """
}