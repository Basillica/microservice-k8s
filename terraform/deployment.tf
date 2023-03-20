resource "kubernetes_deployment" "flask_server" {
  metadata {
    name = "flask-server"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "flask-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-server"
        }
      }

      spec {
        container {
          image = "basillica/rates_api:v1"
          name  = "flask-server"
          port {
            container_port = 3000
          }
          volume_mount {
            name      = "sql-data"
            mount_path = "/data"
          }
        }

        volume {
          name = "sql-data"

          host_path {
            path = "../db/rates.sql"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask_server" {
  metadata {
    name = "flask-service"
  }

  spec {
    selector = {
      app = "flask-server"
    }

    port {
      name       = "http"
      port       = 80
      target_port = 3000
    }

    type = "NodePort"
  }
}


resource "kubernetes_deployment" "postgresql_server" {
  metadata {
    name = "postgresql"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgresql"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgresql"
        }
      }

      spec {
        container {
          image = "postgres:latest"
          name  = "postgresql"
          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }
          env {
            name  = "POSTGRES_DB"
            value = "postgres"
          }
          volume_mount {
            name      = "sql-data"
            mount_path = "/docker-entrypoint-initdb.d/rates.sql"
            sub_path   = "rates.sql"
          }
        }

        volume {
          name = "sql-data"

          host_path {
            path = "../db/rates.sql"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgresql_server" {
  metadata {
    name = "postgresql-service"
  }

  spec {
    selector = {
      app = "postgresql"
    }

    port {
      name       = "postgresql"
      port       = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}
