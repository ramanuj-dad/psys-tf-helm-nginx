# NGINX Ingress Controller Automated Deployment

This repository contains automated tooling for deploying NGINX Ingress Controller on Kubernetes clusters using GitHub Actions and Terraform.

## Architecture

The deployment follows Kubernetes-native security best practices:

1. A GitHub Actions workflow builds a container image with all necessary tools (Terraform, kubectl, helm)
2. The image is pushed to GitHub Container Registry (GHCR)
3. The workflow creates a temporary service account with cluster-admin privileges
4. The workflow deploys a Kubernetes Job that uses this service account
5. The job container executes Terraform to provision the NGINX Ingress Controller
6. After successful apply, the Terraform state is stored in a ConfigMap for later destroy operations
7. When destroying, the workflow loads the state from the ConfigMap before running Terraform destroy
8. On successful deployment, the temporary admin service account is automatically removed

## Security Considerations

- Uses a temporary admin service account that is removed after successful deployment
- Service account is left in place if deployment fails to aid debugging
- No SSH keys or direct node access required
- Clean up of privileged accounts after successful operations

## State Management

This deployment uses a Kubernetes ConfigMap to store and manage Terraform state:

- After successful apply, state is stored in a ConfigMap in the deployment-automation namespace
- Before destroy operations, state is loaded from the ConfigMap
- After successful destroy, the state ConfigMap is deleted
- This approach ensures that destroy operations can find the resources created by apply operations

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

## Version Management

This project uses pinned versions for all components to ensure reproducible and reliable deployments:

### Current Versions
- **NGINX Ingress Helm Chart**: 4.12.3
- **NGINX Ingress Controller**: 1.12.3
- **Controller Image Tag**: v1.12.3

### Configuration
All versions are managed through Terraform variables in `terraform/variables.tf`. To customize versions:

1. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`
2. Modify the version variables as needed
3. Run the deployment workflow

### Version Updates
See [VERSIONS.md](VERSIONS.md) for detailed version management guidelines and update procedures.
