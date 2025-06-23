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
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "deployment_automation" {
  metadata {
    name = "deployment-automation"
  }
}

resource "kubernetes_config_map" "deployment_config" {
  metadata {
    name      = "deployment-config"
    namespace = kubernetes_namespace.deployment_automation.metadata[0].name
  }
  data = {
    cluster_ip = var.cluster_ip
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_config_map" "cluster_info" {
  metadata {
    name      = "cluster-info"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
  data = {
    cluster_ip = var.cluster_ip
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      controller = {
        service = {
          type = "NodePort"
          nodePorts = {
            http  = 30080
            https = 30443
          }
        }
        replicaCount = 1
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
