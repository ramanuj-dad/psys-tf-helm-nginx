output "cluster_ip" {
  value = var.cluster_ip
}

output "deployment_namespace" {
  value = "deployment-automation"
}

output "ingress_namespace" {
  value = kubernetes_namespace.ingress.metadata[0].name
}

output "nginx_ingress_status" {
  value = helm_release.nginx_ingress.status
}
