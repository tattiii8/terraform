terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.0"
    }
  }
}

provider "nomad" {
  address = "${nomad_address}"
}

locals {
  redmine_cpu      = 500
  redmine_memory   = 1024
  postgres_cpu     = 500
  postgres_memory  = 512
  datacenter       = "dc1"
}

# PostgreSQL ジョブ
resource "nomad_job" "postgres" {
  jobspec = file("${path.module}/postgres.hcl")
  detach  = false
}

# Redmine ジョブ
resource "nomad_job" "redmine" {
  jobspec = file("${path.module}/redmine.hcl")
  detach  = false

  depends_on = [nomad_job.postgres]
}

# 出力値
output "postgres_job_id" {
  value       = nomad_job.postgres.id
  description = "PostgreSQL ジョブID"
}

output "redmine_job_id" {
  value       = nomad_job.redmine.id
  description = "Redmine ジョブID"