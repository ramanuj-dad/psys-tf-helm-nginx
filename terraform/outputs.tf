output "cluster_ip" {
  value = var.cluster_ip
}

output "auto_tfe_nginx_namespace" {
  value = kubernetes_namespace.auto_tfe_nginx.metadata[0].name
}

output "ingress_namespace" {
  value = kubernetes_namespace.ingress.metadata[0].name
}

output "nginx_ingress_status" {
  value = helm_release.nginx_ingress.status
}
