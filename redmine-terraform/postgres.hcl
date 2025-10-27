job "postgres" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "postgres" {
    count = 1

    network {
      mode = "bridge"
      port "db" {
        static = 5432
      }
    }

    service {
      name     = "postgres"
      port     = "db"
      provider = "consul"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "${image}"
        ports = ["db"]
      }

      env {
        POSTGRES_DB       = "${db_name}"
        POSTGRES_USER     = "${db_username}"
        POSTGRES_PASSWORD = "${db_password}"
      }

      resources {
        cpu    = ${cpu}
        memory = ${memory}
      }

      volume_mount {
        volume      = "postgres_data"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }
    }

    volume "postgres_data" {
      type   = "host"
      source = "postgres_storage"
    }
  }
}
