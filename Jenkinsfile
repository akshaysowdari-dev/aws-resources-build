// pipeline {
//   agent any

//   environment {
//     AWS_REGION = 'ap-south-2'
//   }

//   stages {

//     stage('Checkout') {
//       steps {
//         git branch: "${env.BRANCH_NAME}", url: 'https://github.com/akshaysowdari-dev/aws-resources-build'
//       }
//     }

//     stage('Set Environment') {
//       steps {
//         script {
//           if (env.BRANCH_NAME == 'develop') {
//             ENV = "dev"
//           } else if (env.BRANCH_NAME == 'test') {
//             ENV = "qa"
//           } else {
//             error "Unsupported branch"
//           }
//         }
//       }
//     }

//     stage('Deploy Infra') {
//       steps {
//         withCredentials([[
//           $class: 'AmazonWebServicesCredentialsBinding',
//           credentialsId: 'aws-dev-creds'
//         ]]) {

//           sh """
//           export AWS_DEFAULT_REGION=${AWS_REGION}

//           cd config

//           ENV=${ENV} terragrunt init
//           ENV=${ENV} terragrunt apply -auto-approve
//           """
//         }
//       }
//     }

//   }
// }




pipeline {
    agent any

    stages {

        stage('Test Git') {
            steps {
                echo 'Git connected successfully'
            }
        }

        stage('Test AWS') {
            steps {
                echo 'Starting AWS Test Stage...'

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-dev-creds'
                ]]) {

                    echo 'AWS credentials injected successfully'

                    sh '''
                        echo "Current user:"
                        whoami

                        echo "AWS CLI version:"
                        aws --version

                        echo "Listing S3 buckets:"
                        aws s3 ls
                    '''
                }

                echo 'AWS Test Stage 2 Completed'
            }
        }

    }
}
