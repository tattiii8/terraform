job "redmine" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "redmine" {
    count = 1

    network {
      mode = "host"
      port "web" {
        static = 3000
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
    }

    task "redmine" {
      driver = "docker"

      config {
        image = "${image}"
        ports = ["web"]
      }

      env {
        REDMINE_DB_POSTGRES = "${db_host}"
        REDMINE_DB_PORT     = "${db_port}"
        REDMINE_DB_USERNAME = "${db_username}"
        REDMINE_DB_PASSWORD = "${db_password}"
        REDMINE_DB_DATABASE = "${db_name}"
      }

      resources {
        cpu    = ${cpu}
        memory = ${memory}
      }
    }
  }
}