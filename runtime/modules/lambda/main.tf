variable "resource_prefix" {}
variable "runtime" {}
variable "handler" {}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name               = "${var.resource_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ZIP Lambda ソースコード
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/api"
  output_path = "${path.module}/lambda.zip"
}

# Lambda Function
resource "aws_lambda_function" "api" {
  function_name = "${var.resource_prefix}-api"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 30
  memory_size = 128
}
