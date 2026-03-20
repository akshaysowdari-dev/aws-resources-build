pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'develop') {
                        env.ENV_FOLDER = 'dev'
                        env.AWS_CREDS = 'aws-dev-creds'
                    } 
                    else if (env.BRANCH_NAME == 'qa') {
                        env.ENV_FOLDER = 'qa'
                        env.AWS_CREDS = 'aws-qa-creds'
                    } 
                    else {
                        error "Branch not allowed for deployment"
                    }

                    echo "Branch: ${env.BRANCH_NAME}"
                    echo "Environment: ${env.ENV_FOLDER}"
                    echo "Using AWS creds: ${env.AWS_CREDS}"
                }
            }
        }

        stage('Deploy Infrastructure') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDS
                    ]]) {

                        sh '''
                            echo "Running Terragrunt for $ENV_FOLDER"

                            cd env/$ENV_FOLDER

                            terragrunt init
                            terragrunt plan
                            terragrunt apply -auto-approve
                        '''
                    }
                }
            }
        }
    }
}