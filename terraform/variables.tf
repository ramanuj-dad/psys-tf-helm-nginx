variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "nginx_ingress_version" {
  description = "Version of the NGINX Ingress Controller Helm chart"
  type        = string
  default     = "4.8.3"
}

variable "cluster_ip" {
  description = "External IP address of the cluster"
  type        = string
  # No default value - must be provided via environment variable or terraform.tfvars
}

variable "namespace" {
  description = "Namespace for NGINX Ingress Controller"
  type        = string
  default     = "ingress-nginx"
}
