terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.0"
    }
  }
}

provider "nomad" {
  address = var.nomad_addr
}

locals {
  datacenter      = "dc1"

  # リソース制限（必要なら後で調整）
  postgres_cpu    = 500
  postgres_memory = 512
  redmine_cpu     = 200
  redmine_memory  = 512
}

# PostgreSQL ジョブ
resource "nomad_job" "postgres" {
  jobspec = templatefile("${path.module}/postgres.hcl", {
    datacenter   = local.datacenter
    image        = var.postgres_image
    db_name      = var.db_name
    db_username  = var.db_username
    db_password  = var.db_password
    cpu          = local.postgres_cpu
    memory       = local.postgres_memory
  })

  detach = false
}

# Redmine ジョブ
resource "nomad_job" "redmine" {
  jobspec = templatefile("${path.module}/redmine.hcl", {
    datacenter  = local.datacenter
    image       = var.redmine_image

    redmine_db_postgres     = var.redmine_db_postgres
    redmine_db_port         = var.redmine_db_port
    redmine_db_username     = var.redmine_db_username
    redmine_db_password     = var.redmine_db_password
    redmine_db_name         = var.redmine_db_name

    cpu         = local.redmine_cpu
    memory      = local.redmine_memory
  })

  detach = false
  depends_on = [nomad_job.postgres]
}

output "postgres_job_id" {
  value       = nomad_job.postgres.id
  description = "PostgreSQL ジョブID"
}

output "redmine_job_id" {
  value       = nomad_job.redmine.id
  description = "Redmine ジョブID"
}
