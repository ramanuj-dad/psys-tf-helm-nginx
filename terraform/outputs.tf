output "cluster_ip" {
  value = var.cluster_ip
}

output "deployment_namespace" {
  value = kubernetes_namespace.deployment_automation.metadata[0].name
}

output "ingress_namespace" {
  value = kubernetes_namespace.ingress.metadata[0].name
}

output "nginx_ingress_status" {
  value = helm_release.nginx_ingress.status
}
