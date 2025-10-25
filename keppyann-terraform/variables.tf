variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "871950640338"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "keppyann"
}

variable "line_channel_access_token" {
  description = "LINE Channel Access Token for keppyann-api"
  type        = string
  sensitive   = true
}

variable "line_channel_access_token_mng" {
  description = "LINE Channel Access Token for keppyann-mng-api"
  type        = string
  sensitive   = true
}