terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_config_map" "cluster_info" {
  metadata {
    name      = "cluster-info"
    namespace = "ingress-nginx"
  }
  data = {
    cluster_ip = var.cluster_ip
  }
}
