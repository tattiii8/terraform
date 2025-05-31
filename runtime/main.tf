module "lambda" {
  source = "./modules/lambda"
  
  resource_prefix = var.resource_prefix
  source_dir      = "${path.root}/api"
}

module "api_gateway" {
  source = "./modules/api-gateway"
  
  resource_prefix      = var.resource_prefix
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}

