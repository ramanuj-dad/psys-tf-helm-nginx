# NGINX Ingress Controller Automated Deployment

This repository contains automated tooling for deploying NGINX Ingress Controller on Kubernetes clusters using GitHub Actions and Terraform.

## Architecture

The deployment follows Kubernetes-native security best practices:

1. A GitHub Actions workflow builds a container image with all necessary tools (Terraform, kubectl, helm)
2. The image is pushed to GitHub Container Registry (GHCR)
3. The workflow deploys a Kubernetes Job in the cluster using the service account authentication
4. The job container executes Terraform to provision the NGINX Ingress Controller

## Security Considerations

- Uses Kubernetes Service Account with properly scoped RBAC permissions
- No SSH keys or direct node access required
- Follows the principle of least privilege

## Prerequisites

Before using this repository:

1. Fork this repository to your GitHub account
2. Add the following secrets to your repository:
   - `KUBE_CONFIG`: The base64-encoded kubeconfig file content with access to your cluster

## Usage

1. Navigate to the Actions tab in your forked repository
2. Run the "Deploy NGINX Ingress Controller" workflow
3. Enter your cluster IP address
4. Choose "apply" to deploy or "destroy" to remove resources

## Implementation Details

The deployment uses:
- Terraform with the Kubernetes and Helm providers for infrastructure as code
- A dedicated namespace (`deployment-automation`) for deployment jobs
- A service account with proper RBAC permissions
- Separate namespace (`ingress-nginx`) for the actual ingress controller resources
