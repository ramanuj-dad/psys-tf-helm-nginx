# Deployment information
output "deployment_namespace" {
  description = "Namespace where the deployment job runs"
  value       = "deployment-automation"
}

output "ingress_namespace" {
  description = "Namespace where NGINX Ingress Controller is deployed"
  value       = kubernetes_namespace.ingress.metadata[0].name
}

output "nginx_ingress_status" {
  description = "Status of the NGINX Ingress Controller Helm release"
  value       = helm_release.nginx_ingress.status
}

# Version information
output "nginx_ingress_chart_version" {
  description = "Version of the NGINX Ingress Helm chart deployed"
  value       = helm_release.nginx_ingress.version
}

output "nginx_ingress_app_version" {
  description = "Application version of NGINX Ingress Controller"
  value       = var.nginx_ingress_app_version
}

output "nginx_ingress_controller_image_tag" {
  description = "Docker image tag of the NGINX Ingress Controller"
  value       = var.nginx_ingress_controller_image_tag
}

# Network configuration
output "http_nodeport" {
  description = "NodePort for HTTP traffic"
  value       = var.http_nodeport
}

output "https_nodeport" {
  description = "NodePort for HTTPS traffic"
  value       = var.https_nodeport
}

# Access information
output "access_instructions" {
  description = "Instructions for accessing applications through the ingress"
  value       = <<-EOT
    NGINX Ingress Controller is now available:
    
    HTTP Access:  http://<NODE_IP>:${var.http_nodeport}
    HTTPS Access: https://<NODE_IP>:${var.https_nodeport}
    
    Replace <NODE_IP> with any of your cluster node IPs.
    
    Chart Version: ${helm_release.nginx_ingress.version}
    App Version: ${var.nginx_ingress_app_version}
    Controller Image: ${var.nginx_ingress_controller_image_tag}
  EOT
}
