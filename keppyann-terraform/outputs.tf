output "api_gateway_url" {
  description = "API Gateway Invoke URL"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.keppyann_api.id
}

output "message_endpoint" {
  description = "Message endpoint URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/message"
}

output "mng_endpoint" {
  description = "Management endpoint URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/mng"
}

output "lambda_api_function_name" {
  description = "Lambda function name for keppyann-api"
  value       = aws_lambda_function.keppyann_api.function_name
}

output "lambda_api_function_arn" {
  description = "Lambda function ARN for keppyann-api"
  value       = aws_lambda_function.keppyann_api.arn
}

output "lambda_mng_api_function_name" {
  description = "Lambda function name for keppyann-mng-api"
  value       = aws_lambda_function.keppyann_mng_api.function_name
}

output "lambda_mng_api_function_arn" {
  description = "Lambda function ARN for keppyann-mng-api"
  value       = aws_lambda_function.keppyann_mng_api.arn
}