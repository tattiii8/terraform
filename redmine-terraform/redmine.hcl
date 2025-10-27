job "redmine" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "redmine" {
    count = 3

    network {
      #mode = "bridge"
      mode = "bridge"
      port "web" {
        to = 3000
      }
    }

    service {
      name     = "redmine"
      port     = "web"
      provider = "consul"

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }

      #connect {
      #  sidecar_service {}
      #}
    }

    task "redmine" {
      driver = "docker"

      config {
        image = "${image}"
        ports = ["web"]
      }

      env {
        REDMINE_DB_POSTGRES = "${redmine_db_postgres}"
        REDMINE_DB_PORT     = "${redmine_db_port}"
        REDMINE_DB_USERNAME = "${redmine_db_username}"
        REDMINE_DB_PASSWORD = "${redmine_db_password}"
        REDMINE_DB_DATABASE = "${redmine_db_name}"
      }

      resources {
        cpu    = ${cpu}
        memory = ${memory}
      }
    }
  }
}