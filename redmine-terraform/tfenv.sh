#!/bin/bash
# Nomad
export TF_VAR_nomad_addr="http://192.168.8.112:4646"
# PostgreSQL
export TF_VAR_db_password="postgres"
export TF_VAR_db_username="postgres"
export TF_VAR_db_postgres="192.168.8.112"
# Redmine
export TF_VAR_redmine_db_password="postgres"
export TF_VAR_redmine_db_username="postgres"
export TF_VAR_redmine_db_postgres="192.168.8.112"
export TF_VAR_redmine_db_port="5432"
export TF_VAR_redmine_db_name="redmine"
# Docker Image
export TF_VAR_redmine_image="redmine:latest"
export TF_VAR_postgres_image="postgres:15"