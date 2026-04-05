# aws-resources-build
Project Overview

Built an end-to-end CI/CD pipeline using Jenkins to automate infrastructure provisioning and deployment across multiple environments (dev, QA, prod) on AWS. The system follows an event-driven architecture where updates to a CSV file in S3 trigger a Lambda function that processes and stores data in DynamoDB.

Architecture
Jenkins (Dockerized) → CI/CD Orchestration
GitHub → Source Control + Webhooks
Terraform + Terragrunt → Infrastructure as Code
AWS S3 → Storage (CSV + Repo Replica)
AWS Lambda → Data Processing
DynamoDB → Data Storage

Key Features
Branch-based deployments (develop → dev, test → QA, release → prod)
Fully automated infrastructure provisioning using Terraform & Terragrunt
Event-driven pipeline (S3 → Lambda → DynamoDB)
Dockerized Jenkins setup for portability
Secure credential management using Jenkins credentials + AWS roles

CI/CD Pipeline Flow
Code pushed to GitHub
Webhook triggers Jenkins pipeline (via ngrok)
Pipeline identifies environment based on branch
Terraform/Terragrunt provisions infrastructure
Post-deployment uploads repo + CSV to S3
S3 event triggers Lambda
Lambda processes CSV and inserts data into DynamoDB

Modules
dynamodb-table → Creates DynamoDB tables (CSV data + repo metadata)
s3-repo-replica → Syncs GitHub repo content to S3
csv-to-dynamodb-job → Lambda function to process CSV and load into DynamoDB

Tech Stack
Jenkins (Docker)
Terraform + Terragrunt
AWS (S3, Lambda, DynamoDB, IAM)
Python (Lambda processing)
GitHub + Webhooks + ngrok

How to Run
Start Jenkins via Docker (localhost:8080)
Configure credentials (AWS + GitHub PAT)
Set up multibranch pipeline
Run ngrok to expose Jenkins
Push code to trigger pipeline

