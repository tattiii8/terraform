#!/bin/bash

export TF_VAR_nomad_address="http://192.168.8.112:4646"

# PostgreSQL 
export TF_VAR_db_password="postgres"
export TF_VAR_db_username="postgres"
export TF_VAR_db_host="192.168.8.112"
export TF_VAR_db_port="5432"
export TF_VAR_db_name="redmine"

# Docker Image
export TF_VAR_redmine_image="redmine:latest"
export TF_VAR_postgres_image="postgres:15"