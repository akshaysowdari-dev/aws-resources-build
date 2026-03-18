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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh 'aws s3 ls'
                }
            }
        }
    }
}