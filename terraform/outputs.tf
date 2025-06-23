output "cluster_ip" {
  value = var.cluster_ip
}

output "ingress_namespace" {
  value = kubernetes_namespace.ingress.metadata[0].name
}
