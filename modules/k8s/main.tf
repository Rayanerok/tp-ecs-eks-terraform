resource "kubernetes_namespace" "app" {
  metadata {
    name = "tf-k8s"
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "ipssi-web"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "ipssi-web"
      }
    }

    template {
      metadata {
        labels = {
          app = "ipssi-web"
        }
      }

      spec {
        image_pull_secrets {
        name = "ecr-secret"
      }
        container {
          name  = "web"
          image = "367496797440.dkr.ecr.us-east-1.amazonaws.com/ipssi-web:v1"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }

            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name      = "ipssi-web"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "ipssi-web"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}
