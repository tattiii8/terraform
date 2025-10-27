variable "nomad_addr" {
  type        = string
  description = "Nomad API address"
}

#PostgreSQL
variable "db_password" {
  type        = string
  description = "PostgreSQL password for Redmine DB user"
}

variable "db_username" {
  type        = string
  description = "PostgreSQL username"
}

variable "db_name" {
  type        = string
  description = "PostgreSQL database name"
  default     = "redmine"
}

variable "postgres_image" {
  type        = string
  description = "Docker image for Postgres"
  default     = "postgres:15"
}

#Redmine
variable "redmine_db_password" {
  type        = string
  description = "PostgreSQL password for Redmine DB user"
}

variable "redmine_db_username" {
  type        = string
  description = "PostgreSQL username"
}

variable "redmine_db_name" {
  type        = string
  description = "PostgreSQL database name"
  default     = "redmine"
}

variable "redmine_db_postgres" {
  type        = string
  description = "PostgreSQL host for Redmine (hostname or IP)"
}

variable "redmine_db_port" {
  type        = string
  description = "PostgreSQL port for Redmine"
  default     = "5432"
}

variable "redmine_image" {
  type        = string
  description = "Docker image for Redmine"
  default     = "redmine:latest"
}
