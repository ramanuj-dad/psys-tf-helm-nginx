# 🚀 NGINX Ingress Controller Deployer

**One-click deployment of NGINX Ingress Controller on bare-metal Kubernetes clusters using containerized automation.**

## ✨ What This Does

- 🐳 **Builds containerized deployer** with Terraform, Helm, kubectl
- 📦 **Pushes to GitHub Container Registry** (GHCR) automatically  
- 🚀 **Deploys as Kubernetes Job** on your cluster
- 🔧 **Uses latest NGINX Ingress Helm chart** for bare-metal clusters
- ✅ **Self-contained and secure** - no SSH dependencies

## 🎯 Quick Start

### 1. Fork This Repository
Click the "Fork" button to create your own copy.

### 2. Setup Your Cluster
Run this **once** on your Kubernetes cluster:
```bash
# Download and run setup script
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/setup-cluster.sh | bash
```

### 3. Configure GitHub Secrets
Go to your repository **Settings → Secrets and variables → Actions** and add:

| Secret Name | Value | Example |
|-------------|--------|---------|
| `TARGET_HOST` | Your cluster IP | `192.168.1.100` |
| `TARGET_USER` | SSH username | `ubuntu` |
| `SSH_PRIVATE_KEY` | SSH private key | `-----BEGIN OPENSSH PRIVATE KEY-----` |
| `SSH_KNOWN_HOSTS` | SSH known hosts | `192.168.1.100 ssh-rsa AAAAB3...` |

### 4. Deploy!
- Go to **Actions** tab in your GitHub repository
- Click **Deploy NGINX Ingress Controller**
- Click **Run workflow**
- Choose `apply` and watch the magic! ✨

## 🏗️ How It Works

```mermaid
graph LR
    A[GitHub Actions] --> B[Build Container]
    B --> C[Push to GHCR]
    C --> D[Deploy K8s Job]
    D --> E[Run Terraform + Helm]
    E --> F[NGINX Ingress Ready!]
```

1. **GitHub Actions** builds a container with all deployment tools
2. **Container** is pushed to GitHub Container Registry (GHCR)
3. **Kubernetes Job** pulls the container and runs deployment
4. **Job** uses Terraform + Helm to deploy NGINX Ingress Controller
5. **Done!** Your ingress is ready at `http://YOUR_CLUSTER_IP/`

## 🌐 Access Your Ingress

After deployment completes:

| Service | URL | Purpose |
|---------|-----|---------|
| **HTTP** | `http://YOUR_CLUSTER_IP/` | Main ingress access |
| **HTTPS** | `https://YOUR_CLUSTER_IP/` | Secure ingress access |
| **NodePort HTTP** | `http://YOUR_CLUSTER_IP:30080/` | Direct NodePort access |
| **NodePort HTTPS** | `http://YOUR_CLUSTER_IP:30443/` | Secure NodePort access |

## 📁 Project Structure

```
.
├── .github/workflows/deploy.yaml    # GitHub Actions workflow
├── docker/Dockerfile               # Container build definition
├── k8s/deployment-job.yaml         # Kubernetes Job template
├── terraform/                      # Terraform configurations
├── helm/values.yaml                # Helm chart values
├── setup-cluster.sh               # One-time cluster setup
└── README.md                       # This file
```

## 🔧 Advanced Usage

### Manual Deployment
Run setup locally:
```bash
# Setup cluster ConfigMap
./setup-cluster.sh

# Deploy manually (if you prefer)
kubectl apply -f k8s/deployment-job.yaml
```

### Destroy Installation
Use the workflow with `destroy` action or run:
```bash
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
```

## 🛠️ Customization

### Helm Values
Edit `helm/values.yaml` to customize NGINX Ingress:
```yaml
controller:
  service:
    type: LoadBalancer
  nodeSelector:
    kubernetes.io/os: linux
```

### Terraform Configuration  
Modify `terraform/main.tf` for infrastructure changes:
```hcl
variable "cluster_ip" {
  description = "External IP address of the cluster"
  type        = string
}
```

## 🔍 Monitoring

Check deployment status:
```bash
# Watch job progress
kubectl logs job/nginx-ingress-deployment-apply -n deployment-automation -f

# Check ingress status
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

## 🚨 Troubleshooting

### Common Issues
1. **Job fails**: Check `kubectl logs job/nginx-ingress-deployment-apply -n deployment-automation`
2. **SSH connection fails**: Verify GitHub Secrets are correctly set
3. **Container pull fails**: Ensure repository is public or configure image pull secrets

### Debug Commands
```bash
# Check ConfigMap
kubectl get configmap deployment-config -n deployment-automation -o yaml

# Check service account permissions
kubectl auth can-i "*" "*" --as=system:serviceaccount:deployment-automation:nginx-ingress-deployer

# Verify cluster IP
kubectl get svc -n ingress-nginx
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🎉 Credits

Built with:
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Terraform](https://terraform.io/)
- [Helm](https://helm.sh/)
- [GitHub Actions](https://github.com/features/actions)

---

**Made with ❤️ for the Kubernetes community**

*One fork, few secrets, infinite possibilities! 🚀*
