variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "source_dir" {
  description = "Directory containing Lambda source code"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}