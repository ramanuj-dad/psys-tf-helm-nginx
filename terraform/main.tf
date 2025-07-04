terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  # Uses in-cluster service account authentication when running in the Kubernetes job
}

provider "helm" {
  kubernetes {
    # Uses in-cluster service account authentication when running in the Kubernetes job
  }
}

# We don't manage the deployment-automation namespace with Terraform
# because the job itself runs in this namespace and it's created outside Terraform.
# This avoids circular dependencies during apply/destroy operations.

# Terraform manages the ingress-nginx namespace completely
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.nginx_ingress_chart_version
  namespace        = kubernetes_namespace.ingress.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      controller = {
        image = {
          tag = var.nginx_ingress_controller_image_tag
        }
        service = {
          type = "ClusterIP"
        }
        hostPort = {
          enabled = true
          ports = {
            http  = 80
            https = 443
          }
        }
        replicaCount = var.controller_replica_count
        tolerations = [
          {
            key      = "node-role.kubernetes.io/control-plane"
            operator = "Equal"
            effect   = "NoSchedule"
          }
        ]
        hostNetwork = true
        dnsPolicy   = "ClusterFirstWithHostNet"
      }
    })
  ]

  depends_on = [kubernetes_namespace.ingress]
}
