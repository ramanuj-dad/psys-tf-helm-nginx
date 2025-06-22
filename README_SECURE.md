# NGINX Ingress Controller Automation

🚀 **Secure, containerized deployment automation for NGINX Ingress Controller on Kubernetes using Terraform and Helm.**

This project provides a complete CI/CD pipeline for deploying NGINX Ingress Controller with enterprise-grade security and automation.

## ✨ **Features**

- 🔐 **Secure by Design**: No hardcoded credentials or IP addresses
- 🐳 **Fully Containerized**: All deployment logic runs in Kubernetes Jobs
- 🚀 **CI/CD Ready**: GitHub Actions workflow with environment isolation
- 🛡️ **Production Ready**: Terraform state management, Helm templating
- 🔄 **Idempotent**: Safe to run multiple times
- 🧹 **Self-Cleaning**: Automatic cleanup of old deployment jobs

## 🚨 **Security Requirements**

### GitHub Secrets Configuration

Before using this project, you **MUST** configure the following secrets in your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `TARGET_HOST` | IP address or hostname of your Kubernetes server | `192.168.1.100` |
| `TARGET_USER` | SSH username for the target server | `ubuntu` |
| `SSH_PRIVATE_KEY` | Private SSH key for authentication | `-----BEGIN OPENSSH PRIVATE KEY-----` |
| `SSH_KNOWN_HOSTS` | SSH known hosts entry for the target server | `192.168.1.100 ssh-rsa AAAAB3...` |

### Setting Up GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each required secret:

```bash
# Generate SSH key pair (if you don't have one)
ssh-keygen -t ed25519 -f ~/.ssh/k8s_deploy -N ""

# Copy public key to target server
ssh-copy-id -i ~/.ssh/k8s_deploy.pub user@target-server

# Get the private key content for GitHub secret
cat ~/.ssh/k8s_deploy

# Get known hosts entry
ssh-keyscan -H your-server-ip
```

### Environment Variables for Local Development

Create a `config.env` file for local testing (never commit this file):

```bash
# config.env - Local development only
TARGET_HOST="your-server-ip"
TARGET_USER="your-username"
CLUSTER_IP="your-server-ip"
```

## 🚀 **Quick Start**

### Prerequisites

- Kubernetes cluster with `kubectl` access
- SSH access to the Kubernetes server
- GitHub repository with required secrets configured

### Deploy via GitHub Actions

1. **Configure Secrets**: Set up all required GitHub secrets (see above)
2. **Trigger Deployment**: 
   - Go to **Actions** tab in your GitHub repository
   - Select **Deploy NGINX Ingress Controller** workflow
   - Click **Run workflow**
   - Choose action: `plan`, `apply`, or `destroy`

### Local Development

```bash
# Clone the repository
git clone <your-repo-url>
cd psys-tower

# Set up environment variables
cp config.env.example config.env
# Edit config.env with your values

# Source environment variables
source config.env

# Run deployment locally
./scripts/deploy.sh apply
```

## 📁 **Project Structure**

```
.
├── .github/workflows/
│   ├── deploy.yaml                 # Main CI/CD workflow
│   └── deploy-containerized.yaml   # Alternative containerized workflow
├── docker/
│   ├── Dockerfile                  # Deployment container
│   └── entrypoint.sh              # Container entry point
├── terraform/
│   ├── main.tf                     # Terraform configuration
│   ├── variables.tf               # Variable definitions
│   └── outputs.tf                 # Output definitions
├── helm/
│   └── values.yaml                # Helm chart values
├── k8s/
│   └── deployment-job.yaml        # Kubernetes Job manifest
├── scripts/
│   ├── deploy.sh                  # Main deployment script
│   ├── test.sh                    # Testing script
│   └── validate.sh               # Validation script
└── examples/
    ├── sample-app.yaml            # Sample application
    └── README.md                  # Examples documentation
```

## 🔧 **Configuration**

### Terraform Variables

The following variables can be customized in `terraform/variables.tf`:

```hcl
variable "nginx_ingress_version" {
  description = "Version of NGINX Ingress Helm chart"
  default     = "4.8.3"
}

variable "cluster_ip" {
  description = "External IP address of the cluster"
  type        = string
  # Must be provided via environment variable TF_VAR_cluster_ip
}

variable "namespace" {
  description = "Namespace for NGINX Ingress Controller"
  default     = "ingress-nginx"
}
```

### Helm Values

Customize NGINX Ingress Controller in `helm/values.yaml`:

```yaml
controller:
  service:
    type: LoadBalancer
    externalIPs:
      - "${cluster_ip}"  # Injected from environment
  nodeSelector:
    kubernetes.io/os: linux
```

## 🧪 **Testing**

### Manual Testing

```bash
# Deploy test application
kubectl apply -f examples/sample-app.yaml

# Test ingress access (replace YOUR_SERVER_IP)
curl -H "Host: demo.local" http://YOUR_SERVER_IP/
curl -H "Host: demo.local" http://YOUR_SERVER_IP/api/health
```

### Automated Testing

The GitHub Actions workflow includes automated testing:

- Terraform plan validation
- Helm chart validation
- Kubernetes manifest validation
- Post-deployment connectivity tests

## 🌐 **Access Information**

After successful deployment, access your NGINX Ingress Controller:

| Service Type | URL Pattern | Description |
|-------------|-------------|-------------|
| **HTTP** | `http://YOUR_SERVER_IP/` | Direct access via host port |
| **HTTPS** | `https://YOUR_SERVER_IP/` | Secure access via host port |
| **NodePort HTTP** | `http://YOUR_SERVER_IP:30080/` | NodePort service access |
| **NodePort HTTPS** | `https://YOUR_SERVER_IP:30443/` | Secure NodePort access |

## 🛠️ **Troubleshooting**

### Common Issues

1. **SSH Connection Failed**
   ```bash
   # Verify SSH key and known hosts
   ssh -i ~/.ssh/your-key user@server-ip
   ```

2. **Terraform Plan Failed**
   ```bash
   # Check if cluster_ip variable is set
   echo $TF_VAR_cluster_ip
   ```

3. **Kubernetes Job Failed**
   ```bash
   # Check job logs
   kubectl logs job/nginx-ingress-deployment-apply -n deployment-automation
   ```

### Debug Commands

```bash
# Check workflow status
kubectl get jobs -n deployment-automation

# View deployment logs
kubectl logs job/nginx-ingress-deployment-apply -n deployment-automation --tail=100

# Check NGINX Ingress status
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

## 🔄 **Workflow Actions**

| Action | Description | When to Use |
|--------|-------------|-------------|
| `plan` | Show what will be deployed | Before applying changes |
| `apply` | Deploy NGINX Ingress Controller | Normal deployment |
| `destroy` | Remove NGINX Ingress Controller | Cleanup/teardown |
| `test` | Run connectivity tests | After deployment |

## 📋 **Prerequisites Checklist**

- [ ] Kubernetes cluster is running and accessible
- [ ] `kubectl` is configured on target server
- [ ] SSH key pair is generated
- [ ] SSH public key is added to target server
- [ ] All GitHub secrets are configured
- [ ] Target server has required permissions

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes (ensure no hardcoded values)
4. Test thoroughly
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ **Security Notes**

- Never commit SSH keys, passwords, or IP addresses to the repository
- Always use GitHub secrets for sensitive information
- Rotate SSH keys regularly
- Monitor access logs on your target servers
- Use least-privilege access principles

---

**Made with ❤️ for secure, automated Kubernetes deployments**
