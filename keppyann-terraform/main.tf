terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }

  backend "s3" {
    bucket         = "flaubert-terraform-state"
    key            = "tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
  }

}

provider "aws" {
  region = var.aws_region
}

# IAM Role for Lambda Execution (keppyann-api)
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role"
    Environment = var.environment
  }
}

# IAM Role for Lambda Execution (keppyann-mng-api)
resource "aws_iam_role" "lambda_mng_role" {
  name = "${var.project_name}-mng-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-mng-api-role"
    Environment = var.environment
  }
}

# Attach basic Lambda execution policy to both roles
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_mng_basic_execution" {
  role       = aws_iam_role.lambda_mng_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM Role for API Gateway
resource "aws_iam_role" "apigateway_role" {
  name = "${var.project_name}-apigateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-apigateway-role"
    Environment = var.environment
  }
}

# API Gateway policy to invoke Lambda
resource "aws_iam_role_policy" "apigateway_lambda_policy" {
  name = "${var.project_name}-apigateway-lambda-policy"
  role = aws_iam_role.apigateway_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.keppyann_api.arn,
          aws_lambda_function.keppyann_mng_api.arn
        ]
      }
    ]
  })
}

# Lambda Function: keppyann-api
resource "aws_lambda_function" "keppyann_api" {
  filename         = "${path.module}/lambda-source/keppyann-api.zip"
  function_name    = "${var.project_name}-api"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda-source/keppyann-api.zip")
  runtime         = "python3.11"
  memory_size     = 128
  timeout         = 30

  environment {
    variables = {
      LINE_CHANNEL_ACCESS_TOKEN = var.line_channel_access_token
    }
  }

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

# Lambda Function: keppyann-mng-api
resource "aws_lambda_function" "keppyann_mng_api" {
  filename         = "${path.module}/lambda-source/keppyann-mng-api.zip"
  function_name    = "${var.project_name}-mng-api"
  role            = aws_iam_role.lambda_mng_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda-source/keppyann-mng-api.zip")
  runtime         = "python3.11"
  memory_size     = 128
  timeout         = 3

  environment {
    variables = {
      LINE_CHANNEL_ACCESS_TOKEN = var.line_channel_access_token_mng
    }
  }

  tags = {
    Name        = "${var.project_name}-mng-api"
    Environment = var.environment
  }
}

# Lambda Permission for API Gateway (keppyann-api)
resource "aws_lambda_permission" "api_gateway_invoke_keppyann_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.keppyann_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.keppyann_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway (keppyann-mng-api)
resource "aws_lambda_permission" "api_gateway_invoke_keppyann_mng_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.keppyann_mng_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.keppyann_api.execution_arn}/*/*"
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "keppyann_api" {
  name        = "${var.project_name}-api"
  description = "Keppyann API Gateway"

  endpoint_configuration {
    types = ["EDGE"]
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:*/*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

# API Gateway Resource: /message
resource "aws_api_gateway_resource" "message" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id
  parent_id   = aws_api_gateway_rest_api.keppyann_api.root_resource_id
  path_part   = "message"
}

# API Gateway Resource: /mng
resource "aws_api_gateway_resource" "mng" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id
  parent_id   = aws_api_gateway_rest_api.keppyann_api.root_resource_id
  path_part   = "mng"
}

# API Gateway Method: POST /message
resource "aws_api_gateway_method" "message_post" {
  rest_api_id   = aws_api_gateway_rest_api.keppyann_api.id
  resource_id   = aws_api_gateway_resource.message.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Method: OPTIONS /message (CORS)
resource "aws_api_gateway_method" "message_options" {
  rest_api_id   = aws_api_gateway_rest_api.keppyann_api.id
  resource_id   = aws_api_gateway_resource.message.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway Method: POST /mng
resource "aws_api_gateway_method" "mng_post" {
  rest_api_id   = aws_api_gateway_rest_api.keppyann_api.id
  resource_id   = aws_api_gateway_resource.mng.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Method: OPTIONS /mng (CORS)
resource "aws_api_gateway_method" "mng_options" {
  rest_api_id   = aws_api_gateway_rest_api.keppyann_api.id
  resource_id   = aws_api_gateway_resource.mng.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway Integration: POST /message -> Lambda
resource "aws_api_gateway_integration" "message_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.keppyann_api.id
  resource_id             = aws_api_gateway_resource.message.id
  http_method             = aws_api_gateway_method.message_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.keppyann_api.invoke_arn
  credentials             = aws_iam_role.apigateway_role.arn
  timeout_milliseconds    = 29000
  passthrough_behavior    = "WHEN_NO_MATCH"
}

# API Gateway Integration: OPTIONS /message (CORS)
resource "aws_api_gateway_integration" "message_options" {
  rest_api_id          = aws_api_gateway_rest_api.keppyann_api.id
  resource_id          = aws_api_gateway_resource.message.id
  http_method          = aws_api_gateway_method.message_options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# API Gateway Integration: POST /mng -> Lambda
resource "aws_api_gateway_integration" "mng_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.keppyann_api.id
  resource_id             = aws_api_gateway_resource.mng.id
  http_method             = aws_api_gateway_method.mng_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.keppyann_mng_api.invoke_arn
  timeout_milliseconds    = 29000
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
}

# API Gateway Integration Response: POST /mng
resource "aws_api_gateway_integration_response" "mng_lambda_response" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id
  resource_id = aws_api_gateway_resource.mng.id
  http_method = aws_api_gateway_method.mng_post.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_integration.mng_lambda]
}

# API Gateway Method Response: POST /mng
resource "aws_api_gateway_method_response" "mng_post_200" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id
  resource_id = aws_api_gateway_resource.mng.id
  http_method = aws_api_gateway_method.mng_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration: OPTIONS /mng (CORS)
resource "aws_api_gateway_integration" "mng_options" {
  rest_api_id          = aws_api_gateway_rest_api.keppyann_api.id
  resource_id          = aws_api_gateway_resource.mng.id
  http_method          = aws_api_gateway_method.mng_options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# API Gateway Method Response: OPTIONS /message (CORS)
resource "aws_api_gateway_method_response" "message_options_200" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id
  resource_id = aws_api_gateway_resource.message.id
  http_method = aws_api_gateway_method.message_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration Response: OPTIONS /message (CORS)
resource "aws_api_gateway_integration_response" "message_options_response" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id
  resource_id = aws_api_gateway_resource.message.id
  http_method = aws_api_gateway_method.message_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.message_options]
}

# API Gateway Method Response: OPTIONS /mng (CORS)
resource "aws_api_gateway_method_response" "mng_options_200" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id
  resource_id = aws_api_gateway_resource.mng.id
  http_method = aws_api_gateway_method.mng_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration Response: OPTIONS /mng (CORS)
resource "aws_api_gateway_integration_response" "mng_options_response" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id
  resource_id = aws_api_gateway_resource.mng.id
  http_method = aws_api_gateway_method.mng_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.mng_options]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "keppyann_api" {
  rest_api_id = aws_api_gateway_rest_api.keppyann_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.message.id,
      aws_api_gateway_resource.mng.id,
      aws_api_gateway_method.message_post.id,
      aws_api_gateway_method.message_options.id,
      aws_api_gateway_method.mng_post.id,
      aws_api_gateway_method.mng_options.id,
      aws_api_gateway_integration.message_lambda.id,
      aws_api_gateway_integration.message_options.id,
      aws_api_gateway_integration.mng_lambda.id,
      aws_api_gateway_integration.mng_options.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.message_lambda,
    aws_api_gateway_integration.message_options,
    aws_api_gateway_integration.mng_lambda,
    aws_api_gateway_integration.mng_options,
    aws_api_gateway_integration_response.message_options_response,
    aws_api_gateway_integration_response.mng_options_response,
    aws_api_gateway_integration_response.mng_lambda_response,
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.keppyann_api.id
  rest_api_id   = aws_api_gateway_rest_api.keppyann_api.id
  stage_name    = var.environment

  tags = {
    Name        = "${var.project_name}-api-${var.environment}"
    Environment = var.environment
  }
}