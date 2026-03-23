provider "aws" {
  region = var.region
}

# -------------------------------
# Package Lambda (zip automatically)
# -------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/python-scripts"
  output_path = "${path.module}/lambda.zip"
}

# -------------------------------
# Lambda IAM Role
# -------------------------------
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project}-${var.env}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# -------------------------------
# Basic CloudWatch Logs Permission
# -------------------------------
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -------------------------------
# Extra Permissions (S3 + DynamoDB)
# -------------------------------
resource "aws_iam_role_policy" "lambda_extra" {
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.csv_store.arn}/*"
      },
      {
        Effect = "Allow",
        Action = ["dynamodb:PutItem"],
        Resource = "*"
      }
    ]
  })
}

# -------------------------------
# Lambda Function
# -------------------------------
resource "aws_lambda_function" "this" {
  function_name = "${var.project}-${var.env}-csv-to-dynamo"

  role    = aws_iam_role.lambda_exec.arn
  handler = "load_to_dynamodb.lambda_handler"
  runtime = "python3.10"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      REGION     = var.region
      PROJECT    = var.project
      ENV        = var.env
      ACCOUNT_ID = var.account_id
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy.lambda_extra
  ]
}

# -------------------------------
# Allow S3 to invoke Lambda
# -------------------------------
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.csv_store.arn
}

# -------------------------------
# S3 Trigger → Lambda
# -------------------------------
resource "aws_s3_bucket_notification" "trigger" {
  bucket = aws_s3_bucket.csv_store.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}