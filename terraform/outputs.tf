# No need for cluster_ip output

output "deployment_namespace" {
  value = "deployment-automation"
}

output "ingress_namespace" {
  value = kubernetes_namespace.ingress.metadata[0].name
}

output "nginx_ingress_status" {
  value = helm_release.nginx_ingress.status
}
