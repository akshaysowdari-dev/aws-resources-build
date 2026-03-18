variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "env_short" {
  description = "Short env name"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
}