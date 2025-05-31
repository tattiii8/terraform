# terraform/modules/lambda/main.tf

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

# 依存関係をインストールするためのnullリソース
resource "null_resource" "pip_install" {
  count = fileexists("${var.source_dir}/requirements.txt") ? 1 : 0
  
  triggers = {
    requirements = filesha256("${var.source_dir}/requirements.txt")
    source_code  = sha256(join("", [for f in fileset(var.source_dir, "*.py") : filesha256("${var.source_dir}/${f}")]))
  }

  provisioner "local-exec" {
    command = <<EOF
      cd ${var.source_dir}
      rm -rf package
      mkdir -p package
      pip install -r requirements.txt -t package/
      cp *.py package/
    EOF
  }
}

# Lambda deployment package (依存関係がある場合)
data "archive_file" "lambda_zip_with_deps" {
  count = fileexists("${var.source_dir}/requirements.txt") ? 1 : 0
  
  type        = "zip"
  source_dir  = "${var.source_dir}/package"
  output_path = "${path.module}/api_with_deps.zip"
  
  depends_on = [null_resource.pip_install]
}

# Lambda deployment package (依存関係がない場合)
data "archive_file" "lambda_zip_simple" {
  count = fileexists("${var.source_dir}/requirements.txt") ? 0 : 1
  
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/api_simple.zip"
}

# Lambda function
resource "aws_lambda_function" "api" {
  depends_on = [aws_iam_role.lambda_role]
  
  filename         = fileexists("${var.source_dir}/requirements.txt") ? data.archive_file.lambda_zip_with_deps[0].output_path : data.archive_file.lambda_zip_simple[0].output_path
  function_name    = "${var.resource_prefix}-api"
  role             = aws_iam_role.lambda_role.arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = fileexists("${var.source_dir}/requirements.txt") ? data.archive_file.lambda_zip_with_deps[0].output_base64sha256 : data.archive_file.lambda_zip_simple[0].output_base64sha256
  
  # タイムアウトを延長（外部API呼び出しのため）
  timeout     = 30
  memory_size = 128

  tags = {
    Name = "${var.resource_prefix}-api"
  }
}