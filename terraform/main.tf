terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Configure the Kubernetes Provider
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# Configure the Helm Provider
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

# Create namespace for ingress-nginx
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      name = "ingress-nginx"
    }
  }
}

# Deploy NGINX Ingress Controller using Helm
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = var.nginx_ingress_version

  # Use custom values file for bare-metal setup
  values = [
    file("${path.module}/../helm/values.yaml")
  ]

  # Set additional values for bare-metal single-node setup
  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.externalIPs[0]"
    value = var.cluster_ip
  }

  set {
    name  = "controller.hostPort.enabled"
    value = "true"
  }

  set {
    name  = "controller.hostPort.ports.http"
    value = "80"
  }

  set {
    name  = "controller.hostPort.ports.https"
    value = "443"
  }

  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  set {
    name  = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }

  # Tolerate control-plane taints for single-node cluster
  set {
    name  = "controller.tolerations[0].key"
    value = "node-role.kubernetes.io/control-plane"
  }

  set {
    name  = "controller.tolerations[0].operator"
    value = "Equal"
  }

  set {
    name  = "controller.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "controller.tolerations[1].key"
    value = "node-role.kubernetes.io/master"
  }

  set {
    name  = "controller.tolerations[1].operator"
    value = "Equal"
  }

  set {
    name  = "controller.tolerations[1].effect"
    value = "NoSchedule"
  }

  depends_on = [kubernetes_namespace.ingress_nginx]

  # Wait for deployment to be ready
  wait    = true
  timeout = 300
}
