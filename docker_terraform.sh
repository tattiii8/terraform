#!bin/bash

export AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID" 
export AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY" 
export AWS_SESSION_TOKEN="AWS_SESSION_TOKEN" 
export TERRAFORM_VERSION="1.6.0" 

TERRAFORM_VERSION="${TERRAFORM_VERSION}" 

docker run --rm \
  -v //Users/tatsuki/terraform:/terraform \
  -w /terraform \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  -e AWS_DEFAULT_REGION="ap-northeast-1" \
  -it --entrypoint=ash \
  hashicorp/terraform:${TERRAFORM_VERSION} \

 