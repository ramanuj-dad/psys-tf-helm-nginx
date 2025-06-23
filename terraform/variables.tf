# Version management for reproducible deployments
variable "nginx_ingress_chart_version" {
  description = "Version of the NGINX Ingress Helm chart"
  type        = string
  default     = "4.12.3"
}

variable "nginx_ingress_app_version" {
  description = "Version of the NGINX Ingress Controller application"
  type        = string
  default     = "1.12.3"
}

variable "nginx_ingress_controller_image_tag" {
  description = "Docker image tag for the NGINX Ingress Controller"
  type        = string
  default     = "v1.12.3"
}

# Network configuration
variable "http_nodeport" {
  description = "NodePort for HTTP traffic"
  type        = number
  default     = 30080
}

variable "https_nodeport" {
  description = "NodePort for HTTPS traffic"
  type        = number
  default     = 30443
}

# Deployment configuration
variable "controller_replica_count" {
  description = "Number of NGINX Ingress Controller replicas"
  type        = number
  default     = 1
}
